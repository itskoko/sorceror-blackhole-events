require 'robust-redis-lock'

module Sorceror
  class Operation
    def self.process(message)
      new(message).process
    end

    def initialize(message)
      @message = message
    end

    def process
      instrumented { process! }
    end

    def process!
      Table.create!(Sorceror.table_name)
      persist
    end

    def update_schema
    end

    def persist
      DB[Sorceror.table_name].insert(@message.as_sequel)
      Sorceror.info "[sorceror-blackhole][persist] #{@message.type}/#{@message.name}/#{@message.id}"
    end

    private

    def instrumented(&block)
      block.call
    end
  end
end
