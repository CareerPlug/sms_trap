# frozen_string_literal: true

require 'test_helper'

module SmsTrap
  class ConversationTest < ActiveSupport::TestCase
    test 'key is symmetric regardless of message from/to order' do
      outbound = Message.new(1, '+15550001111', '+15552223333', 'hi', 'outbound', Time.current)

      assert_equal Conversation.key_for('+15552223333', '+15550001111'), Conversation.new([outbound]).key
    end

    test 'our_number and their_number derive from an outbound message' do
      outbound = Message.new(1, '+15550001111', '+15552223333', 'hi', 'outbound', Time.current)
      conversation = Conversation.new([outbound])

      assert_equal '+15550001111', conversation.our_number
      assert_equal '+15552223333', conversation.their_number
    end

    test 'our_number and their_number derive from an inbound message when no outbound exists' do
      inbound = Message.new(1, '+15552223333', '+15550001111', 'reply', 'inbound', Time.current)
      conversation = Conversation.new([inbound])

      assert_equal '+15550001111', conversation.our_number
      assert_equal '+15552223333', conversation.their_number
    end
  end
end
