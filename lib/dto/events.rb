# frozen_string_literal: true

require 'json'

module DTO
  # Imports and processes events
  class Events < Base
    attr_reader :transactions_set,
                :loyalty_events_set,
                :membership_events_set

    def transactions
      time_scoped.where(event_type: 'transactions')
    end

    def loyalty_events
      time_scoped.where(event_type: %w[profile_completion
                                       wheel_spin
                                       additional_questions])
    end

    def membership_create_events
      time_scoped.where(event_type: 'transactions')
    end

    def build_transactions_set
      @transactions_set = transactions.map do |row|
        context = parse_context(row[:context])
        transaction = context.find do |resource|
          resource[:type] == 'transactions'
        end

        transaction[:id]
      end.to_set
    end

    def build_loyalty_events_set
      @loyalty_events_set = loyalty_events.map do |row|
        context = parse_context(row[:context])
        loyalty_event = context.find do |resource|
          resource[:type] == 'loyalty_events'
        end
        loyalty_event[:id]
      end
    end

    def build_membership_events_set
      @membership_events_set = membership_create_events.map do |row|
        context = parse_context(row[:context])
        membership = context.find do |resource|
          resource[:type] == 'memberships'
        end
        membership[:id]
      end
    end

    private

    def default_connection
      Sequel.connect(ENV['RULE_SERVICE_DB_URI'])
    end

    def parse_context(context)
      # Unescape overescaped json.
      context.sub!(/^"/, '')
      context.sub!(/^\\"/, '')
      context.sub!(/"$/, '')
      context.delete!('\\')
      JSON.parse(context, symbolize_names: true)
    end

    def table
      conn[:events]
    end
  end
end
