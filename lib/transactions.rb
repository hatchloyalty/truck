# frozen_string_literal: true

require 'csv'
require 'pg'

# Imports transactions
class Transactions
  attr_reader :table, :set

  def initialize(conn = default_connection)
    @conn = conn
  end

  def import
    path = File.expand_path(
      File.join(File.dirname(__FILE__), '..', 'data', 'transactions.csv')
    )
    @table = CSV.table(path)
  end

  def load
    query = <<~SQL
      SELECT id
      FROM transactions
      WHERE created_at > $1
    SQL
    query += " AND created_at <= $2" if end_at
    @membership_events = @conn.exec(query, [start_at, end_at].compact)
    @table = @conn.exec(query, [start_at, end_at].compact)
  end

  def find(ids)
    return [] if ids.empty?
    id_list = ids.reduce('') { |str, id| str + "'#{id}', " }[0..-3]
    query = <<~SQL
      SELECT id, created_at
      FROM transactions
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

  def start_at
    ENV['START_AT'].empty? ? nil : ENV['START_AT']
  end

  def end_at
    ENV['END_AT'].empty? ? nil : ENV['END_AT']
  end
end
