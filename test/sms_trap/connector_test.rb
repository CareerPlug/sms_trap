# frozen_string_literal: true

require 'test_helper'

module SmsTrap
  class ConnectorTest < ActiveSupport::TestCase
    test 'send_message records to the store and returns id/time/direction' do
      store = Store.new
      connector = Connector.new(store: store)

      result = connector.send_message(from: '+15550001111', to: '+15552223333', text: 'hello')

      assert result.id
      assert result.time
      assert_equal 'outbound', result.direction

      recorded = store.conversations.first.messages.first
      assert_equal 'hello', recorded.text
      assert_equal '+15550001111', recorded.from
      assert_equal '+15552223333', recorded.to
    end
  end
end
