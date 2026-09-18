# frozen_string_literal: true

module SmsTrap
  # Thread-safe, in-process store of every message SmsTrap has intercepted. A single instance
  # lives for the life of the process at {SmsTrap.store}.
  class Store
    def initialize
      @messages = []
      @mutex = Mutex.new
      @next_id = 0
    end

    # Records a single message.
    #
    # @param from [String] the sending phone number
    # @param to [String] the receiving phone number
    # @param text [String] the message body
    # @param direction [String] "outbound" or "inbound"
    # @param sent_at [Time] when the message was sent; defaults to now
    # @return [Message] the recorded message, with its assigned id
    def record(from:, to:, text:, direction:, sent_at: Time.zone.now)
      @mutex.synchronize do
        @next_id += 1
        message = Message.new(@next_id, from, to, text, direction, sent_at)
        @messages << message
        message
      end
    end

    # @return [Array<Conversation>] every conversation recorded so far, most-recently-active first
    def conversations
      messages_snapshot
        .group_by { |message| Conversation.key_for(message.from, message.to) }
        .values
        .map { |messages| Conversation.new(messages) }
        .sort_by { |conversation| conversation.messages.first.sent_at }
        .reverse
    end

    # Discards every recorded message.
    #
    # @return [void]
    def clear
      @mutex.synchronize { @messages.clear }
    end

    private

    def messages_snapshot
      @mutex.synchronize { @messages.dup }
    end
  end
end
