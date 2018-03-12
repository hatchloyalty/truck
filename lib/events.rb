# frozen_string_literal: true

require 'csv'
require 'json'
require 'pg'

# Imports and processes events
class Events
  attr_reader :transaction_events,
              :transactions_set,
              :loyalty_events,
              :loyalty_events_set
  def initialize(conn = default_connection)
    @conn = conn
  end

  def load_transactions
    query = <<~SQL
      SELECT id, context
      FROM events
      WHERE created_at > $1
      AND event_type = 'transactions'
    SQL
    @transaction_events = @conn.exec(query, [ENV['START_AT']])
  end

  def load_loyalty_events
    query = <<~SQL
      SELECT id, context
      FROM events
      WHERE created_at > $1
      AND event_type in ('profile_completion', 'wheel_spin', 'additional_questions')
    SQL
    @loyalty_events = @conn.exec(query, [ENV['START_AT']])
  end

  def build_transactions_set
    @transactions_set = transaction_events.map do |row|
      context = parse_context(row['context'])
      transaction = context.find do |resource|
        resource[:type] == 'transactions'
      end

      transaction[:id]
    end.to_set
  end

  def build_loyalty_events_set
    @loyalty_events_set = loyalty_events.map do |row|
      context = parse_context(row['context'])
      loyalty_event = context.find do |resource|
        resource[:type] == 'loyalty_events'
      end
      loyalty_event[:id]
    end
  end

  private

  def default_connection
    PG.connect(ENV['RULE_SERVICE_DB_URI'])
  end

  def parse_context(context)
    JSON.parse(
      JSON.parse(context), symbolize_names: true
    )
  end
end
