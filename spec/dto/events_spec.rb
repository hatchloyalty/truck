require 'spec_helper'

RSpec.describe(DTO::Events) do
  it "Can handle parsing an event with double-escaped quoted json" do
    db = Sequel.sqlite
    db.create_table :events do
      primary_key :id
      String :event_type
      String :context
      datetime :created_at
    end
    events_table = db[:events]
    badson = <<~BADSON
      \\\"[{\\\\\"id\\\\\":\\\\\"2fe5175f-6a27-4e4f-91b8-e18104d5c8d9\\\\\",\\\\\"type\\\\\":\\\\\"transactions\\\\\",\\\\\"links\\\\\":{\\\\\"self\\\\\":\\\\\"/api/v2/transactions/2fe5175f-6a27-4e4f-91b8-e18104d5c8d9\\\\\"},\\\\\"attributes\\\\\":{\\\\\"created_at\\\\\":\\\\\"2017-10-02T12:36:41.713Z\\\\\",\\\\\"custom_data\\\\\":{},\\\\\"line_items\\\\\":[{\\\\\"id\\\\\":\\\\\"89df1acf-8a2f-48dc-a22a-3f1c49ced160\\\\\",\\\\\"transaction_id\\\\\":\\\\\"2fe5175f-6a27-4e4f-91b8-e18104d5c8d9\\\\\",\\\\\"sku\\\\\":null,\\\\\"promo_code\\\\\":null,\\\\\"quantity\\\\\":3.0,\\\\\"money_amount\\\\\":4.47,\\\\\"upc\\\\\":\\\\\"042100005264\\\\\",\\\\\"group\\\\\":\\\\\"sodas-drinks\\\\\"}],\\\\\"location_id\\\\\":null,\\\\\"membership_id\\\\\":\\\\\"c3c8ad9f-c7db-4a02-8bcc-c58211df564c\\\\\",\\\\\"money_currency_code\\\\\":\\\\\"USD\\\\\",\\\\\"partner_id\\\\\":null,\\\\\"points_earned_override\\\\\":null,\\\\\"fulfilled_offer_ids\\\\\":[],\\\\\"redemption_ids\\\\\":[\\\\\"f874e699-6d67-44d3-9f64-b1e0c050165f\\\\\"],\\\\\"request_id\\\\\":\\\\\"fd2a8831-b537-4efb-8339-aae47f225ddc\\\\\",\\\\\"transaction_time_at\\\\\":\\\\\"2017-10-02T12:35:00.000Z\\\\\"}},{\\\\\"id\\\\\":\\\\\"c3c8ad9f-c7db-4a02-8bcc-c58211df564c\\\\\",\\\\\"type\\\\\":\\\\\"memberships\\\\\",\\\\\"links\\\\\":{\\\\\"self\\\\\":\\\\\"/api/v2/memberships/c3c8ad9f-c7db-4a02-8bcc-c58211df564c\\\\\"},\\\\\"attributes\\\\\":{\\\\\"created_at\\\\\":\\\\\"2017-10-02T12:36:21.052Z\\\\\",\\\\\"birthdate\\\\\":null,\\\\\"chain_id\\\\\":\\\\\"d55d2ad5-094f-413b-ba58-75591bf30654\\\\\",\\\\\"custom_data\\\\\":{},\\\\\"email\\\\\":\\\\\"alvis.hackett@example.com\\\\\",\\\\\"name\\\\\":\\\\\"Alvis Hackett\\\\\",\\\\\"phone\\\\\":\\\\\"0125766643\\\\\",\\\\\"points\\\\\":0,\\\\\"state\\\\\":\\\\\"unconfirmed\\\\\"},\\\\\"relationships\\\\\":{\\\\\"point_transactions\\\\\":{\\\\\"links\\\\\":{\\\\\"self\\\\\":\\\\\"/api/v2/memberships/c3c8ad9f-c7db-4a02-8bcc-c58211df564c/relationships/point_transactions\\\\\",\\\\\"related\\\\\":\\\\\"/api/v2/memberships/c3c8ad9f-c7db-4a02-8bcc-c58211df564c/point_transactions\\\\\"}},\\\\\"point_changes\\\\\":{\\\\\"links\\\\\":{\\\\\"self\\\\\":\\\\\"/api/v2/memberships/c3c8ad9f-c7db-4a02-8bcc-c58211df564c/relationships/point_changes\\\\\",\\\\\"related\\\\\":\\\\\"/api/v2/memberships/c3c8ad9f-c7db-4a02-8bcc-c58211df564c/point_changes\\\\\"}},\\\\\"chain\\\\\":{\\\\\"links\\\\\":{\\\\\"self\\\\\":\\\\\"/api/v2/memberships/c3c8ad9f-c7db-4a02-8bcc-c58211df564c/relationships/chain\\\\\",\\\\\"related\\\\\":\\\\\"/api/v2/memberships/c3c8ad9f-c7db-4a02-8bcc-c58211df564c/chain\\\\\"}},\\\\\"offers\\\\\":{\\\\\"links\\\\\":{\\\\\"self\\\\\":\\\\\"/api/v2/memberships/c3c8ad9f-c7db-4a02-8bcc-c58211df564c/relationships/offers\\\\\",\\\\\"related\\\\\":\\\\\"/api/v2/memberships/c3c8ad9f-c7db-4a02-8bcc-c58211df564c/offers\\\\\"}},\\\\\"unfulfilled_redemptions\\\\\":{\\\\\"links\\\\\":{\\\\\"self\\\\\":\\\\\"/api/v2/memberships/c3c8ad9f-c7db-4a02-8bcc-c58211df564c/relationships/unfulfilled_redemptions\\\\\",\\\\\"related\\\\\":\\\\\"/api/v2/memberships/c3c8ad9f-c7db-4a02-8bcc-c58211df564c/unfulfilled_redemptions\\\\\"}}}}]\\\"
    BADSON

    events_table.insert(event_type: 'transactions',
                        context: badson,
                        created_at: Date.today)

    events = DTO::Events.new(from: Date.today - 1, conn: db)
    events.build_transactions_set
    expect(events.transactions_set.length).to eq(1)
  end
end
