# frozen_string_literal: true

module SmsTrap
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
