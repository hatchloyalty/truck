# frozen_string_literal: true

# Data Transfer Objects
module Truck
  module DTO
  end
end

require 'sequel'
require 'pg'
require_relative 'dto/base'
require_relative 'dto/events'
require_relative 'dto/loyalty_events'
require_relative 'dto/transactions'
require_relative 'dto/memberships'
