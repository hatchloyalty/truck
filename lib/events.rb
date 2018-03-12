# frozen_string_literal: true

require 'csv'
require 'json'
require 'pg'

# Imports and processes events
class Events
  attr_reader :transaction_events,
              :transactions_set,
              :loyalty_events,
              :loyalty_events_set,
              :membership_events,
              :membership_events_set
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
    query += " AND created_at <= $2" if end_at
    @transaction_events = @conn.exec(query, [start_at, end_at].compact)
  end

  def load_loyalty_events
    query = <<~SQL
      SELECT id, context
      FROM events
      WHERE created_at > $1
      AND event_type in ('profile_completion', 'wheel_spin', 'additional_questions')
    SQL
    query += " AND created_at <= $2" if end_at
    @loyalty_events = @conn.exec(query, [start_at, end_at].compact)
  end

  def load_membership_create_events
    query = <<~SQL
      SELECT id, context
      from events
      where created_at > $1
      and event_type in ('loyalty_events')
    SQL
    query += " AND created_at <= $2" if end_at
    @membership_events = @conn.exec(query, [start_at, end_at].compact)
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

  def build_membership_events_set
    @membership_events_set = membership_events.map do |row|
      context = parse_context(row['context'])
      membership = context.find do |resource|
        resource[:type] == 'memberships'
      end
      membership[:id]
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

  def start_at
    ENV['START_AT'].empty? ? nil : ENV['START_AT']
  end

  def end_at
    ENV['END_AT'].empty? ? nil : ENV['END_AT']
  end
end
