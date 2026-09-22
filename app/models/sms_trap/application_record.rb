# frozen_string_literal: true

module SmsTrap
  # Base class for the SmsTrap engine's ActiveRecord models. Currently unused — SmsTrap
  # stores messages as files (see {Store}) rather than in a database.
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
