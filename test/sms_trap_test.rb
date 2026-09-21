# frozen_string_literal: true

require 'test_helper'

class SmsTrapTest < ActiveSupport::TestCase
  test 'it has a version number' do
    assert SmsTrap::VERSION
  end

  test 'reply_handler returns the configured handler' do
    handler = ->(from:, to:, text:) {}

    with_reply_handler(handler) do
      assert_equal handler, SmsTrap.reply_handler
    end
  end

  test 'reply_handler raises a clear error when unset' do
    with_reply_handler(nil) do
      assert_raises(SmsTrap::ReplyHandlerNotConfigured) { SmsTrap.reply_handler }
    end
  end

  test 'reply_handler? reflects whether a handler is configured' do
    with_reply_handler(nil) do
      assert_not SmsTrap.reply_handler?
    end

    with_reply_handler(->(from:, to:, text:) {}) do
      assert SmsTrap.reply_handler?
    end
  end
end
