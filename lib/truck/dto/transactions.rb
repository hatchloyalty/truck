# frozen_string_literal: true

module Truck
  module DTO
    # Imports transactions
    class Transactions < Base
      attr_reader :set

      def find(ids)
        table.where(id: ids)
      end

      def build_set
        @set = time_scoped.map { |r| r[:id] }.to_set
      end

      private

      def default_connection
        Sequel.connect(ENV['CORE_SERVICE_DB_URI'])
      end

      def table
        conn[:transactions]
      end
    end
  end
end
