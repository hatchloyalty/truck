# frozen_string_literal: true

module Truck
  module DTO
    # Base class for Data Transfer Objects
    class Base
      attr_reader :from, :to, :conn
      def initialize(from:, to: Date.today, conn: default_connection)
        @conn = conn
        @from = from
        @to = to
      end

      def time_scoped
        table.where(created_at: from..to)
      end

      private

      def table
        raise 'Implement in subclass'
      end

      def default_connection
        # Sequel.connect(ENV['DB_URL'])
        raise 'Implement in subclass'
      end
    end
  end
end
