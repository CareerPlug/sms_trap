# frozen_string_literal: true

module SmsTrap
  # Handles a dev submitting a reply in the UI: triggers the host app's real inbound path via
  # {SmsTrap.reply_handler}, then records the reply so it shows up as an inbound bubble.
  class RepliesController < ApplicationController
    def create
      conversation = find_conversation
      return head(:not_found) unless conversation

      simulate_reply(conversation)
      redirect_to conversation_path(conversation)
    end

    private

    def find_conversation
      SmsTrap.store.conversations.find { |c| c.to_param == params[:conversation_id] }
    end

    def simulate_reply(conversation)
      from = conversation.their_number
      to = conversation.our_number
      text = params[:text]

      SmsTrap.reply_handler.call(from: from, to: to, text: text)
      SmsTrap.store.record(from: from, to: to, text: text, direction: 'inbound')
    end
  end
end
