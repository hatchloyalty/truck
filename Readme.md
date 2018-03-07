# TRUCK

A project to identify the missing transactions.

## Outline

- [x] Export CSV of `transactions` table
- [x] Export CSV of `events` table
- [x] Import transactions into memory
- [x] Build a set of Transactions by id
- [x] Import events into memory
- [x] Filter the events down to only `event_type == transactions`
- [x] Parse the context field of events
- [x] Build a set of the events by transaction_id
- [x] Get the difference of `transactions - events`
