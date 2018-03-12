# frozen_string_literal: true

require 'csv'
require 'pg'

# Imports loyalty_events
class LoyaltyEvents
  attr_reader :table, :set

  def initialize(conn = default_connection)
    @conn = conn
  end

  def load
    query = <<~SQL
      SELECT id
      FROM loyalty_events
      WHERE created_at > $1
    SQL
    @table = @conn.exec(query, [ENV['START_AT']])
  end

  def find(ids)
    return [] if ids.empty?
    id_list = ids.reduce('') { |str, id| str + "'#{id}', " }[0..-3]
    query = <<~SQL
      SELECT id, created_at
      FROM loyalty_events
      WHERE id in (#{id_list})
    SQL
    @conn.exec(query)
  end

  def build_set
    @set = @table.map { |r| r['id'] }.to_set
  end

  private

  def default_connection
    PG.connect(ENV['CORE_SERVICE_DB_URI'])
  end
end