# frozen_string_literal: true

require 'json'

module Truck
  module DTO
    # Imports and processes events
    class Events < Base
      attr_reader :transactions_set,
                  :loyalty_events_set,
                  :membership_events_set

      def transactions
        time_scoped.where(event_type: ['transactions', 'transactions.created'])
      end

      def loyalty_events
        time_scoped.where(event_type: %w[profile_completion
                                         wheel_spin
                                         additional_questions
                                         enrollment_completion
                                         age_gated_offer
                                         abandoned_membership
                                         loyalty_events.created])
      end

      def membership_create_events
        time_scoped.where(event_type: ['loyalty_events',
                                       'loyalty_events.created'])
      end

      def build_transactions_set
        @transactions_set = transactions.map do |row|
          context = parse_context(row[:context])
          transaction = context.find do |resource|
            resource[:type] == 'transactions'
          end
          next if transaction.nil?

          transaction[:id]
        end.to_set
      end

      def build_loyalty_events_set
        @loyalty_events_set = loyalty_events.map do |row|
          context = parse_context(row[:context])
          loyalty_event = context.find do |resource|
            resource[:type] == 'loyalty_events'
          end
          next if loyalty_event.nil?
          loyalty_event[:id]
        end
      end

      def build_membership_events_set
        @membership_events_set = membership_create_events.map do |row|
          context = parse_context(row[:context])
          extract_membership_id(context)
        end
      end

      private

      def extract_membership_id(context)
        context.reduce(nil) do |result, resource|
          if resource.fetch(:type) == 'memberships'
            resource[:id]
          elsif resource.fetch(:type) == 'loyalty_events' &&
                resource.dig(:attributes, :event_type) == 'membership_create'
            resource.dig(:attributes, :event_data, :membership_id)
          else
            result
          end
        end
      end

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
end
