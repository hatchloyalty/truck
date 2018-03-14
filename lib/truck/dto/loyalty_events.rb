# frozen_string_literal: true

module Truck
  module DTO
    # Imports loyalty_events
    class LoyaltyEvents < Base
      attr_reader :set

      def find(ids)
        table.where(id: ids)
      end

      def loyalty_events
        time_scoped.exclude(event_type: 'birthday')
      end

      def build_set
        @set = loyalty_events.map { |r| r[:id] }.to_set
      end

      private

      def default_connection
        Sequel.connect(ENV['CORE_SERVICE_DB_URI'])
      end

      def table
        conn[:loyalty_events]
      end
    end
  end
end
