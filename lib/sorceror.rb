require 'active_support/dependencies/autoload'
require 'active_support/core_ext'

$:.unshift File.dirname(__FILE__)

module Sorceror
  mattr_accessor :kafka_hosts
  mattr_accessor :zookeeper_hosts
  mattr_accessor :topic
  mattr_accessor :logger
  mattr_accessor :attribute_filter
  mattr_accessor :threads
  mattr_accessor :table_name

  GROUP = 'koko-sorceror-blackhole-events'

  require 'sorceror/autoload'
  extend Sorceror::Autoload

  autoload :DB, :Operation, :Message, :Table, :Worker

  def self.lock(key)
    Redis::Lock.new(key)
  end

  [:debug, :info, :warn, :error].each do |logger_level|
    define_singleton_method(logger_level) do |*args|
      Sorceror.logger.send(logger_level, *args) if Sorceror.logger
    end
  end
end
