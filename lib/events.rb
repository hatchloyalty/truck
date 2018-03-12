# frozen_string_literal: true

require 'csv'
require 'json'
require 'pg'

# Imports and processes events
class Events
  attr_reader :table, :set
  def initialize(conn = default_connection)
    @conn = conn
  end

  def import
    path = File.expand_path(
      File.join(__FILE__, '..', '..', 'data', 'events.csv')
    )
    @table = CSV.table(path, {})
  end

  def load
    query = <<~SQL
      SELECT id, context
      FROM events
      WHERE created_at > $1
      AND event_type = 'transactions'
    SQL
    @table = @conn.exec(query, [ENV['START_AT']])
  end

  def build_set
    @set = table.map do |row|
      context = JSON.parse(
        JSON.parse(row['context']), symbolize_names: true
      )
      transaction = context.find { |resource| resource[:type] == 'transactions' }
      transaction[:id]
    end.to_set
  end

  private

  def default_connection
    PG.connect(ENV["RULE_SERVICE_DB_URI"])
  end
end
