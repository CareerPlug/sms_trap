# frozen_string_literal: true

require 'test_helper'

class ReplyTest < ActionDispatch::IntegrationTest
  setup { SmsTrap.store.clear }

  test 'submitting a reply invokes the configured reply_handler and records an inbound message' do
    SmsTrap::Connector.new.send_message(from: '+15550001111', to: '+15552223333', text: 'hello there')
    conversation = SmsTrap.store.conversations.first
    invocations = []

    with_reply_handler(->(from:, to:, text:) { invocations << { from: from, to: to, text: text } }) do
      post "/sms_trap/conversations/#{conversation.to_param}/reply", params: { text: 'got it, thanks' }
    end

    assert_redirected_to "/sms_trap/conversations/#{conversation.to_param}"
    assert_equal [{ from: '+15552223333', to: '+15550001111', text: 'got it, thanks' }], invocations

    get "/sms_trap/conversations/#{conversation.to_param}"
    assert_match 'sms-trap-bubble--inbound', response.body
    assert_match 'got it, thanks', response.body
  end

  test 'show renders the reply form only when a reply_handler is configured' do
    SmsTrap::Connector.new.send_message(from: '+15550001111', to: '+15552223333', text: 'hello there')
    conversation = SmsTrap.store.conversations.first

    with_reply_handler(->(from:, to:, text:) {}) do
      get "/sms_trap/conversations/#{conversation.to_param}"
      assert_select 'form.sms-trap-reply-form', 1
    end

    with_reply_handler(nil) do
      get "/sms_trap/conversations/#{conversation.to_param}"
      assert_select 'form.sms-trap-reply-form', 0
    end
  end

  test 'submitting a reply without a configured reply_handler raises' do
    SmsTrap::Connector.new.send_message(from: '+15550001111', to: '+15552223333', text: 'hello there')
    conversation = SmsTrap.store.conversations.first

    with_reply_handler(nil) do
      assert_raises(SmsTrap::ReplyHandlerNotConfigured) do
        post "/sms_trap/conversations/#{conversation.to_param}/reply", params: { text: 'got it' }
      end
    end
  end
end
