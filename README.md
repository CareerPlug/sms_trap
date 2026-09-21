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

## Simulating inbound replies

Typing a reply in the SmsTrap UI can trigger your app's real inbound-webhook path — not a
fake success, the same code that runs when your provider posts a genuine webhook. Configure
it by setting `SmsTrap.reply_handler` in a development-only initializer to any callable
responding to `#call(from:, to:, text:)`:

```ruby
# config/initializers/sms_trap.rb
SmsTrap.reply_handler = lambda do |from:, to:, text:|
  # Build whatever wire format your provider's webhook expects, and POST it to your app's
  # own webhook endpoint (e.g. via ActionDispatch::Integration::Session), the same way your
  # provider's real webhook call would land — SmsTrap never touches this format itself.
  YourApp::Sms::Adapter.new.simulate_reply(from: from, to: to, text: text)
end
```

SmsTrap doesn't know or care what's inside the callable — it stays exactly as
provider-agnostic on the inbound side as `Connector` is on the outbound side. All it
guarantees is that your handler gets *called* with the reply's `from`/`to`/`text`; whether
your app's downstream logic does anything observable (e.g. matching an active conversation
thread) is entirely up to your app's real code, same as it would be for a genuine provider
webhook.

If no `reply_handler` is configured, the reply form doesn't render at all — apps that don't
need inbound simulation don't need to set anything up.

## Roadmap

None currently — outbound interception and inbound reply simulation are both shipped.
Feature requests are welcome via GitHub issues.

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
