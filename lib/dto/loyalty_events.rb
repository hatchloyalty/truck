# frozen_string_literal: true

module DTO
  # Imports loyalty_events
  class LoyaltyEvents < Base
    attr_reader :set

    def initialize(conn = default_connection)
      @conn = conn
    end

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
      conn[:loyalty_events]
    end
  end

end
