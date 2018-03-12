# frozen_string_literal: true

require 'truck/version'

module Truck
  # Box to put the run instructions in
  class Runner
    attr_reader :transactions, :events, :unmatched_transactions
    def initialize
      @transactions = Transactions.new
      @events = Events.new
    end

    def collect_unmatched_transactions
      transactions.load
      transactions.build_set

      events.load
      events.build_set

      @unmatched_ts = transactions.set - events.set
    end

    def fetch_transaction_data(transaction_ids)
      transactions.find(transaction_ids)
    end

    def run
      collect_unmatched_transactions
      return print 'No missing transactions' if unmatched_ts.empty?
      transaction_data = transactions.find(unmatched_ts)
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
