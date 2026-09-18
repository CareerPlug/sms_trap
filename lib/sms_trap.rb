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

  class << self
    # @return [Store] the process-wide store every {Connector} records into by default
    def store
      @store ||= Store.new
    end
  end
end
