# frozen_string_literal: true

require 'csv'

class Events
  attr_reader :table
  def import
    path = File.expand_path(
      File.join(__FILE__, '..', '..', 'data', 'events.csv')
    )
    @table = CSV.table(path, {})
  end
end
