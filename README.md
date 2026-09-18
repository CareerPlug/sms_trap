# SmsTrap

A local SMS interception and viewing UI for development — Mailtrap for SMS.

SmsTrap intercepts outbound SMS sends in development so nothing ever reaches a real phone,
and shows them in a phone-styled browser UI (conversation list, chat bubbles). It's a
**visualization tool**, not a testing framework — it's for seeing what your app would send,
not for exercising API failure/retry paths (those stay covered by your app's own unit specs).

SmsTrap is provider-agnostic. It doesn't know about Bandwidth, Twilio, AWS, or any other SMS
vendor, and it never fabricates provider-specific wire formats. Instead, it exposes a single
duck-typed interface — `#send_message(from:, to:, text:)` — the same shape as
`ActiveJob::QueueAdapters`, `ActiveStorage::Service`, or `ActionMailer`'s `delivery_method`.
Your host app points its SMS delivery layer at `SmsTrap::Connector` in development, the same
way it points at a real provider adapter in production.

## Installation

Add this line to your application's Gemfile, scoped to development:

```ruby
group :development do
  gem "sms_trap"
end
```

And then execute:
```bash
$ bundle
```

## Usage

Mount the engine, scoped to development:

```ruby
# config/routes.rb
mount SmsTrap::Engine => "/sms_trap" if Rails.env.development?
```

Point your app's SMS delivery layer at `SmsTrap::Connector` in development. The connector
implements a single method:

```ruby
SmsTrap::Connector.new.send_message(from: "+15550001111", to: "+15552223333", text: "hello")
# => #<struct SmsTrap::Connector::Result id="20260918153012123456-a1b2c3d4", time=..., direction="outbound">
```

Wherever your app sends outbound SMS, swap in `SmsTrap::Connector` for your real provider
adapter when `Rails.env.development?`. The result responds to `.id`, `.time`, and
`.direction`, matching what most SMS delivery code reads off a successful send.

Visit `/sms_trap` to see every intercepted message, grouped into conversations by phone
number pair, most-recent-first, rendered as chat bubbles in a phone-styled UI.

Intercepted messages are persisted as files under `tmp/sms_trap` in the host app, not held
in memory, so they're visible across every worker process — including a clustered Puma dev
server — and survive server restarts until explicitly cleared with `SmsTrap.store.clear`.

## Roadmap

Inbound reply simulation — typing a reply in the SmsTrap UI and having it flow back into
your app exactly as a real inbound webhook would — is planned for a later release. Its
interface will be designed once outbound interception has seen real usage.

## Contributing

Bug reports and pull requests are welcome on GitHub.

### Local development

This gem is scaffolded as a mountable Rails engine with a dummy app under `test/dummy`, so
you can exercise it end-to-end without a host app.

```bash
bundle install
bin/rails test          # run the test suite
bundle exec rubocop     # lint
```

To try the UI in a browser:

```bash
bin/rails server
```

Then visit `http://localhost:3000` — the dummy app's root page is a small form (not part of
the gem itself, just a stand-in for wherever a real host app sends SMS) that calls
`SmsTrap::Connector` directly. Submit it, then visit `http://localhost:3000/sms_trap` to see
the message show up in the conversation list and thread view.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
