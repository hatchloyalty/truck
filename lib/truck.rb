# frozen_string_literal: true

require 'truck/version'

module Truck
  # Box to put the run instructions in
  class Runner
    def run
      txs = Transactions.new
      txs.load
      txs.build_set

      evs = Events.new
      evs.load
      evs.build_set

      unmatched_ts = txs.set - evs.set
      transaction_data = txs.find(unmatched_ts)
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
