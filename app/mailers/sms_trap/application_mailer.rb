# frozen_string_literal: true

module SmsTrap
  # Base class for the SmsTrap engine's mailers. Currently unused.
  class ApplicationMailer < ActionMailer::Base
    default from: 'from@example.com'
    layout 'mailer'
  end
end
