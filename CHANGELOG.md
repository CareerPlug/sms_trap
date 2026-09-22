# Changelog

## v0.2.0 (2026-09-22)

- Add inbound reply simulation: trigger the host app's real inbound-webhook path from the
  SmsTrap UI via a configurable `SmsTrap.reply_handler`
- Make `Store` filesystem-backed so intercepted messages survive clustered Puma workers and
  dev server restarts
- Add a button to clear all intercepted messages from the conversation index
- Derive `Conversation#key` from `anchor_message`, matching `our_number`/`their_number`
- Add `Conversation#to_param`, remove duplicated key-joining logic
- Remove unused `SmsTrap.enable!`/`enabled?`
- Add a dummy-app compose form for manual browser testing
- Enable `Style/Documentation`, add YARD docs to the public library API

## v0.1.0 (2026-09-18)

- Initial release: outbound SMS interception via `SmsTrap::Connector`, and a phone-styled
  browser UI for viewing intercepted messages grouped into conversations
