require 'robust-redis-lock'

module Sorceror
  class Table
    def self.create!(name)
      self.new(name).create
    end

    def initialize(table_name)
      @table_name = table_name
    end

    def create
      create! if needs_creation?
    end

    private

    attr_reader :table_name

    def create!
      Redis::Lock.new(table_name.to_s).synchronize do
        ensure_created
      end
    end

    def needs_creation?
      !DB.tables.include?(table_name.to_sym)
    end

    def ensure_created
      DB.create_table?(table_name) do
        primary_key :seq

        column :id, :char, size: 48
        column :name, :text
        column :attributes, :json
        column :type, :text
      end

      DB.alter_table(table_name) do
        add_index :name
        add_index :type
        add_index :id
      end

      Sorceror.info "[sorceror-blackhole] Created table #{table_name}"
    end
  end
end
