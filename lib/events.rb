# frozen_string_literal: true

require 'csv'
require 'json'

class Events
  attr_reader :table
  def import
    path = File.expand_path(
      File.join(__FILE__, '..', '..', 'data', 'events.csv')
    )
    @table = CSV.table(path, {})
  end

  def select_transactions
    table.delete_if { |r| r[:event_type] != "transactions" }
  end

  def parse_context
    table.each { |r| r[:context] = JSON.parse(JSON.parse(r[:context])) }
  end

  def build_set
  end
end
