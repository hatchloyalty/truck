# frozen_string_literal: true

require 'date'
require 'csv'
require 'truck/version'
require 'truck/dto'

module Truck
  # Box to put the run instructions in
  class Runner
    attr_reader :transactions,
                :events,
                :loyalty_events,
                :memberships,
                :unmatched_transactions,
                :unmatched_loyalty_events,
                :unmatched_memberships
    def initialize(from: default_from, to: default_to)
      @transactions = DTO::Transactions.new(from: from, to: to)
      @events = DTO::Events.new(from: from, to: to)
      @loyalty_events = DTO::LoyaltyEvents.new(from: from, to: to)
      @memberships = DTO::Memberships.new(from: from, to: to)
    end

    def collect_unmatched_transactions
      transactions.build_set
      events.build_transactions_set

      @unmatched_transactions = transactions.set - events.transactions_set
    end

    def collect_unmatched_loyalty_events
      loyalty_events.build_set
      events.build_loyalty_events_set
      @unmatched_loyalty_events = loyalty_events.set - events.loyalty_events_set
    end

    def collect_unmatched_memberships
      memberships.build_set
      events.build_membership_events_set
      @unmatched_memberships = memberships.set - events.membership_events_set
    end

    def run
      collect_unmatched_transactions
      collect_unmatched_loyalty_events
      collect_unmatched_memberships
      write_transactions
      write_loyalty_events
      write_memberships
    end

    private

    def default_from
      Date.parse(ENV['START_AT'])
    end

    def default_to
      ENV['END_AT'].empty? ? Date.today : Date.parse(ENV['END_AT'])
    end

    def write_transactions
      return print "No missing transactions\n" if unmatched_transactions.empty?
      transaction_data = transactions.find(unmatched_transactions.to_a)
      write('transactions.csv', transaction_data.map { |row| [row[:id], row[:created_at]] })
      print "Missing Transactions written to `transactions.csv`\n"
    end

    def write_loyalty_events
      return print "No missing loyalty events\n" if unmatched_loyalty_events.empty?
      data = loyalty_events.find(unmatched_loyalty_events.to_a)
      write('loyalty_events.csv', data.map { |row| [row[:id], row[:created_at]] })
      print "Missing Loyalty Events written to `loyalty_events.csv`\n"
    end

    def write_memberships
      return print "No missing memberships\n" if unmatched_memberships.empty?
      data = memberships.find(unmatched_memberships.to_a)
      write('memberships.csv', data.map { |row| [row[:id], row[:created_at]] })
      print "Missing Memberships written to `memberships.csv`\n"
    end

    def write(file, data)
      CSV.open(file, 'w') do |csv|
        data.each do |datum|
          csv << datum
        end
      end
    end
  end
end
