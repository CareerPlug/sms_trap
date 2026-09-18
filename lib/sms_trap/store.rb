# frozen_string_literal: true

module SmsTrap
  class Store
    def initialize
      @messages = []
      @mutex = Mutex.new
      @next_id = 0
    end

    def record(from:, to:, text:, direction:, sent_at: Time.zone.now)
      @mutex.synchronize do
        @next_id += 1
        message = Message.new(@next_id, from, to, text, direction, sent_at)
        @messages << message
        message
      end
    end

    def conversations
      messages_snapshot
        .group_by { |message| Conversation.key_for(message.from, message.to) }
        .values
        .map { |messages| Conversation.new(messages) }
        .sort_by { |conversation| conversation.messages.first.sent_at }
        .reverse
    end

    def clear
      @mutex.synchronize { @messages.clear }
    end

    private

    def messages_snapshot
      @mutex.synchronize { @messages.dup }
    end
  end
end
