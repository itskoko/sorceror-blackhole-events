require 'robust-redis-lock'

module Sorceror
  class Table
    def self.create!(name)
      self.new(name).create
    end

    @@created = false

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
        @@created = true
      end
    end

    def needs_creation?
      !@@created
    end

    def ensure_created
      if !DB.tables.include?(table_name.to_sym)
        DB.create_table?(table_name) do
          primary_key :seq
        end

        Sorceror.info "[sorceror-blackhole] Creating table #{table_name}"
      end

      (columns.keys - Sorceror::DB[table_name].columns).each do |column|
        column_args = columns[column]
        DB.alter_table(table_name) do
          add_column column, *column_args

          add_index column
        end
        Sorceror.info "[sorceror-blackhole] Adding column #{column}"
      end
    end

    def columns
      {
        id:         [:char, { size: 48 }],
        at:         [:timestamptz],
        name:       [:text],
        attributes: [:json],
        type:       [:text]
      }
    end
  end
end
