# frozen_string_literal: true

module SmsTrap
  # Mountable Rails engine exposing the SmsTrap conversation-viewing UI.
  class Engine < ::Rails::Engine
    isolate_namespace SmsTrap
  end
end
