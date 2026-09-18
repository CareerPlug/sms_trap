# frozen_string_literal: true

module SmsTrap
  class Conversation
    attr_reader :messages

    def self.key_for(from, to)
      [from, to].sort
    end

    def initialize(messages)
      @messages = messages.sort_by(&:sent_at).reverse
    end

    def key
      self.class.key_for(messages.first.from, messages.first.to)
    end

    def to_param
      key.join(',')
    end

    def our_number
      anchor_message&.direction == 'outbound' ? anchor_message.from : anchor_message&.to
    end

    def their_number
      anchor_message&.direction == 'outbound' ? anchor_message.to : anchor_message&.from
    end

    private

    def anchor_message
      messages.find(&:outbound?) || messages.find(&:inbound?)
    end
  end
end
