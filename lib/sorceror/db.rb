module Sorceror
  module DB
    @@connection = nil

    def self.connect(url, cfg={})
      @@connection.try(:disconnect)

      @@connection = Sequel.connect(url, cfg.merge(:max_connections => 10))
      extension :pg_json, :pg_array
    end

    def self.[](arg)
      @@connection[arg.to_sym]
    end

    def self.method_missing(method, *args, &block)
      @@connection.public_send(method, *args, &block)
    end
  end
end
