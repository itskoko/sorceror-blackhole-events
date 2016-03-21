Bundler.require
require File.expand_path('../../lib/sorceror', __FILE__)

Sorceror.kafka_hosts      = [ENV["KAFKA_HOST"]]
Sorceror.zookeeper_hosts  = [ENV["ZOOKEEPER_HOST"]]
Sorceror.topic            = ENV["TOPIC"]
Sorceror.threads          = ENV["SORCEROR_WORKERS"].to_i
Sorceror.table_name       = ENV["TABLE_NAME"]

Sorceror.logger = Logger.new(STDOUT)
Sorceror.logger.level = ENV["LOGGER_LEVEL"].to_i

Sorceror::DB.connect(ENV["DATABASE_URL"], sslmode: ENV["DATABASE_SSLMODE"])

Redis::Lock.redis = Redis.new(url: ENV["REDIS_URL"]) 
