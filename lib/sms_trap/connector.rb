# frozen_string_literal: true

module SmsTrap
  class Connector
    Result = Struct.new(:id, :time, :direction)

    def initialize(store: SmsTrap.store)
      @store = store
    end

    def send_message(from:, to:, text:)
      message = @store.record(from: from, to: to, text: text, direction: 'outbound')
      Result.new(message.id, message.sent_at, message.direction)
    end
  end
end
