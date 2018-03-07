# frozen_string_literal: true

require 'csv'
require 'json'

# Imports and processes events
class Events
  attr_reader :table, :set
  def import
    path = File.expand_path(
      File.join(__FILE__, '..', '..', 'data', 'events.csv')
    )
    @table = CSV.table(path, {})
  end

  def select_transactions
    table.delete_if { |r| r[:event_type] != 'transactions' }
  end

  def parse_context
    table.each do |row|
      row[:context] = JSON.parse(
        JSON.parse(row[:context]), symbolize_names: true
      )
    end
  end

  def build_set
    @set = table.map do |row|
      row[:context].find { |resource| resource[:type] == 'transactions' }[:id]
    end.to_set
  end
end
