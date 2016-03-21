module Sorceror
  class Worker
    class JRuby
      def self.run
        return if @consumer

        require 'jruby-kafka'

        options = {
          :topic_id => Sorceror.topic,
          :zk_connect => Sorceror.zookeeper_hosts.join(','),
          :group_id => GROUP,
          :auto_commit_enable => "false",
          :auto_offset_reset => 'smallest',
          :consumer_restart_on_error => "false"
        }

        @consumer = Kafka::Group.new(options)

        %w(SIGTERM SIGINT).each do |signal|
          Signal.trap(signal) do
            puts "Stopping..."
            @consumer.shutdown
          end
        end

        @consumer.run(Sorceror.threads) do |message, metadata|
          begin
            message = Message.new(message)
            Operation.new(message).process
            @consumer.commit(metadata)
          rescue StandardError => e
            Sorceror.logger.error "Shutting down due to #{e.message}:#{e.stacktrace.join("\n")}"
            Raven.capture_exception(e)
            @consumer.shutdown
          end
        end

        puts "Started"
      end
    end

    class MRI
      @@instance = nil

      def self.run
        return if @@instance

        require 'poseidon_cluster'

        starting = true
        stop = false

        @@instance = self.new

        %w(SIGTERM SIGINT).each do |signal|
          Signal.trap(signal) do
            puts "Stopping..."
            stop = true
          end
        end

        loop do
          @@instance.fetch

          if starting
            puts "Started"
            starting = false
          end

          sleep 1

          if stop
            @@instance.stop
            break
          end
        end
      ensure
        @@instance = nil
      end

      def consumer
        @consumer ||= ::Poseidon::ConsumerGroup.new(GROUP,
                                                    Sorceror.kafka_hosts,
                                                    Sorceror.zookeeper_hosts,
                                                    Sorceror.topic,
                                                    :trail        => true,
                                                    :max_bytes    => 2**20,
                                                    :min_bytes    => 0,
                                                    :max_wait_ms  => 10)
      end

      def fetch
        consumer.fetch do |partition, payloads|
          payloads.each do |payload|
            begin
              message = Message.new(payload.value)
              Operation.new(message).process
            rescue StandardError => e
              Raven.capture_exception(e)
              raise e
            end
          end
        end
      end

      def reset!
        consumer.instance_eval do
          partitions.each do |partition|
            zk.delete(offset_path(partition[:id]), :ignore => :no_node)
          end
        end
        stop
      end

      def stop
        @consumer.close if @consumer
        @consumer = nil
      end
    end
  end
end
