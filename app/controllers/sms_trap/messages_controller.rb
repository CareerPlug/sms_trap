# frozen_string_literal: true

module SmsTrap
  # Wipes every intercepted message, for clearing out clutter built up during manual testing.
  class MessagesController < ApplicationController
    def destroy
      SmsTrap.store.clear
      redirect_to conversations_path
    end
  end
end
