# frozen_string_literal: true

require 'test_helper'

class NavigationTest < ActionDispatch::IntegrationTest
  setup { SmsTrap.store.clear }

  test 'index lists conversations and links to their thread' do
    SmsTrap::Connector.new.send_message(from: '+15550001111', to: '+15552223333', text: 'hello there')

    get '/sms_trap'

    assert_response :success
    assert_match '+15552223333', response.body
    assert_match 'hello there', response.body
  end

  test 'show renders the intercepted message as a bubble' do
    SmsTrap::Connector.new.send_message(from: '+15550001111', to: '+15552223333', text: 'hello there')
    conversation = SmsTrap.store.conversations.first

    get "/sms_trap/conversations/#{conversation.key.join(',')}"

    assert_response :success
    assert_match 'sms-trap-bubble--outbound', response.body
    assert_match 'hello there', response.body
  end
end
