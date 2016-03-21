module Sorceror
  class Message
    def initialize(raw)
      @raw = raw
    end

    def attributes
      parsed['attributes']
    end

    def name
      parsed['name']
    end

    def type
      parsed['type']
    end

    def id
      parsed['id']
    end

    def to_s
      "<Message:#{ parsed }>"
    end

    def parsed
      @parsed ||= JSON.load(@raw)
    end

    def as_sequel
      {
        id: id,
        name: name,
        type: type,
        attributes: Sequel.pg_json(attributes)
      }
    end
  end
end
