# frozen_string_literal: true

RSpec.describe Truck do
  it 'has a version number' do
    expect(Truck::VERSION).not_to be nil
  end
end
