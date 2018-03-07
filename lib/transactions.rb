# frozen_string_literal: true

require 'csv'

class Transactions
  attr_reader :table, :set
  def import
    path = File.expand_path(
      File.join(File.dirname(__FILE__), '..', 'data', 'transactions.csv')
    )
    @table = CSV.table(path)
  end

  def build_set
    @set = @table.map{ |r| r[:id] }
  end
end
