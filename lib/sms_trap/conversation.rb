# frozen_string_literal: true

module SmsTrap
  # Groups the messages exchanged between the same two phone numbers, regardless of which one
  # sent the most recent message.
  class Conversation
    # @return [Array<Message>] messages in the conversation, most-recent-first
    attr_reader :messages

    # Builds a conversation's identity from a pair of phone numbers, independent of which one
    # is "from" and which is "to".
    #
    # @param from [String] one phone number in the pair
    # @param to [String] the other phone number in the pair
    # @return [Array<String>] the pair, sorted for stable, order-independent identity
    def self.key_for(from, to)
      [from, to].sort
    end

    # @param messages [Array<Message>] the messages that make up this conversation
    def initialize(messages)
      @messages = messages.sort_by(&:sent_at).reverse
    end

    # @return [Array<String>] this conversation's order-independent identity
    def key
      self.class.key_for(anchor_message.from, anchor_message.to)
    end

    # @return [String] the value used to identify this conversation in a URL
    def to_param
      key.join(',')
    end

    # @return [String, nil] the host app's own number
    def our_number
      anchor_message&.direction == 'outbound' ? anchor_message.from : anchor_message&.to
    end

    # @return [String, nil] the other party's number
    def their_number
      anchor_message&.direction == 'outbound' ? anchor_message.to : anchor_message&.from
    end

    private

    # The message used to determine number ownership: the newest outbound message if one
    # exists, otherwise the newest inbound message.
    #
    # @return [Message, nil]
    def anchor_message
      messages.find(&:outbound?) || messages.find(&:inbound?)
    end
  end
end
