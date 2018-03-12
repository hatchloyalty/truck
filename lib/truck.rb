# frozen_string_literal: true

require 'truck/version'

module Truck
  # Box to put the run instructions in
  class Runner
    attr_reader :transactions,
                :events,
                :loyalty_events,
                :unmatched_transactions,
                :unmatched_loyalty_events
    def initialize
      @transactions = Transactions.new(from: ENV['START_AT'], to: ENV['END_AT'])
      @events = Events.new(from: ENV['START_AT'], to: ENV['END_AT'])
      @loyalty_events = LoyaltyEvents.new(
        from: ENV['START_AT'],
        to: ENV['END_AT']
      )
    end

    def collect_unmatched_transactions
      transactions.build_set
      events.build_set

      @unmatched_transactions = transactions.set - events.set
    end

    def collect_unmatched_loyalty_events
      loyalty_events.build_set
      events.build_loyalty_events_set
      @unmatched_loyalty_events = loyalty_events.set - events.loyalty_events_set
    end

    def run
      collect_unmatched_transactions
      return print 'No missing transactions' if unmatched_transactions.empty?
      transaction_data = transactions.find(unmatched_transactions)
      write(transaction_data.map { |row| [row['id'], row['created_at']] })
    end

    def write(data)
      CSV.open('out.csv', 'w') do |csv|
        data.each do |datum|
          csv << datum
        end
      end
    end
  end
end
