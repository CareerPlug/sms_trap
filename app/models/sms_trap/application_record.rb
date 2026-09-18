# frozen_string_literal: true

module SmsTrap
  # Base class for the SmsTrap engine's ActiveRecord models. Currently unused — SmsTrap
  # stores messages in-process (see {Store}) rather than persisting them.
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
