# frozen_string_literal: true

module SmsTrap
  class ConversationsController < ApplicationController
    def index
      @conversations = SmsTrap.store.conversations
    end

    def show
      @conversation = SmsTrap.store.conversations.find { |conversation| conversation.key.join(',') == params[:id] }
      head :not_found unless @conversation
    end
  end
end
