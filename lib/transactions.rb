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
    @table = @conn.exec(query, [ENV['START_AT']])
  end

  def find(ids)
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
end
