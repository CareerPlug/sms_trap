# frozen_string_literal: true

module SmsTrap
  # The provider-agnostic delivery adapter host apps point their SMS-sending code at in
  # development, in place of a real provider adapter (Twilio, Bandwidth, etc).
  class Connector
    # @!attribute id
    #   @return [String] the recorded message's id
    # @!attribute time
    #   @return [Time] when the message was sent
    # @!attribute direction
    #   @return [String] always "outbound"
    Result = Struct.new(:id, :time, :direction)

    # @param store [Store] where sent messages are recorded; defaults to the process-wide store
    def initialize(store: SmsTrap.store)
      @store = store
    end

    # Records an outbound message as sent.
    #
    # @param from [String] the sending phone number
    # @param to [String] the receiving phone number
    # @param text [String] the message body
    # @return [Result] responds to #id, #time, and #direction
    def send_message(from:, to:, text:)
      message = @store.record(from: from, to: to, text: text, direction: 'outbound')
      Result.new(message.id, message.sent_at, message.direction)
    end
  end
end
