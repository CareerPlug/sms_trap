# frozen_string_literal: true

require 'test_helper'

class ClearMessagesTest < ActionDispatch::IntegrationTest
  setup { SmsTrap.store.clear }

  test 'destroying messages clears every conversation and redirects to the index' do
    SmsTrap::Connector.new.send_message(from: '+15550001111', to: '+15552223333', text: 'hello there')

    delete '/sms_trap/messages'

    assert_redirected_to '/sms_trap/conversations'
    assert_empty SmsTrap.store.conversations
  end

  test 'index offers a way to clear all messages' do
    SmsTrap::Connector.new.send_message(from: '+15550001111', to: '+15552223333', text: 'hello there')

    get '/sms_trap'

    assert_select 'form[action=?][method=?]', '/sms_trap/messages', 'post' do
      assert_select 'input[name=?][value=?]', '_method', 'delete'
    end
  end
end
