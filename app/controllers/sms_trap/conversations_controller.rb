# frozen_string_literal: true

module SmsTrap
  # Renders intercepted messages, grouped into conversations by phone number pair.
  class ConversationsController < ApplicationController
    def index
      @conversations = SmsTrap.store.conversations
    end

    def show
      @conversation = SmsTrap.store.conversations.find { |conversation| conversation.to_param == params[:id] }
      head :not_found unless @conversation
    end
  end
end
