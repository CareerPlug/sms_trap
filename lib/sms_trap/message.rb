# frozen_string_literal: true

module SmsTrap
  # A single SMS message intercepted by SmsTrap, sent by the host app ("outbound") or
  # simulated as a reply ("inbound").
  #
  # @!attribute id
  #   @return [Integer] the message's id, assigned when it's recorded
  # @!attribute from
  #   @return [String] the sending phone number
  # @!attribute to
  #   @return [String] the receiving phone number
  # @!attribute text
  #   @return [String] the message body
  # @!attribute direction
  #   @return [String] "outbound" or "inbound"
  # @!attribute sent_at
  #   @return [Time] when the message was sent
  Message = Struct.new(:id, :from, :to, :text, :direction, :sent_at) do
    # @return [Boolean] whether this message was sent by the host app
    def outbound?
      direction == 'outbound'
    end

    # @return [Boolean] whether this message was received by the host app
    def inbound?
      direction == 'inbound'
    end
  end
end
