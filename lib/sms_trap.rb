# frozen_string_literal: true

require 'sms_trap/version'
require 'sms_trap/engine'
require 'sms_trap/message'
require 'sms_trap/conversation'
require 'sms_trap/store'
require 'sms_trap/connector'

module SmsTrap
  class Error < StandardError; end

  class << self
    def store
      @store ||= Store.new
    end

    def enable!
      @enabled = true
    end

    def enabled?
      @enabled == true
    end
  end
end
