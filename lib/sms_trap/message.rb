# frozen_string_literal: true

module SmsTrap
  Message = Struct.new(:id, :from, :to, :text, :direction, :sent_at) do
    def outbound?
      direction == 'outbound'
    end

    def inbound?
      direction == 'inbound'
    end
  end
end
