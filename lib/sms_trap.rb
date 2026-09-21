# frozen_string_literal: true

require 'sms_trap/version'
require 'sms_trap/engine'
require 'sms_trap/message'
require 'sms_trap/conversation'
require 'sms_trap/store'
require 'sms_trap/connector'

# SmsTrap intercepts outbound SMS sends in development and shows them in a phone-styled
# browser UI, so nothing ever reaches a real phone. See {Connector} for the interface host
# apps point their SMS delivery layer at.
module SmsTrap
  class Error < StandardError; end

  # Raised when {reply_handler} is read before the host app has configured one.
  class ReplyHandlerNotConfigured < Error; end

  class << self
    # @return [Store] the process-wide store every {Connector} records into by default
    def store
      @store ||= Store.new
    end

    # @param handler [#call] called with from:/to:/text: when a dev submits a reply in the
    #   UI, to trigger the host app's real inbound path — see README for wiring examples
    attr_writer :reply_handler

    # @return [#call] the configured reply handler
    # @raise [ReplyHandlerNotConfigured] if the host app hasn't set one
    def reply_handler
      @reply_handler || raise(ReplyHandlerNotConfigured,
                              'Set SmsTrap.reply_handler in an initializer, e.g. ' \
                              'SmsTrap.reply_handler = ->(from:, to:, text:) { ... }. See README.')
    end

    # @return [Boolean] whether a reply handler has been configured
    def reply_handler?
      @reply_handler.present?
    end
  end
end
