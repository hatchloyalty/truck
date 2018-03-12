# frozen_string_literal: true

module DTO
  # Imports memberships
  class Memberships < Base
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
      conn[:memberships]
    end
  end
end
