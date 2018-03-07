# frozen_string_literal: true

require 'csv'

class Transactions
  attr_reader :table
  def import
    path = File.expand_path(
      File.join(__FILE__, '..', '..', 'data', 'transactions.csv')
    )
    @table = CSV.table(path, {})
  end
end
