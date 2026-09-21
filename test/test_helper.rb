# frozen_string_literal: true

# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require_relative '../test/dummy/config/environment'
ActiveRecord::Migrator.migrations_paths = [File.expand_path('../test/dummy/db/migrate', __dir__)]
ActiveRecord::Migrator.migrations_paths << File.expand_path('../db/migrate', __dir__)
require 'rails/test_help'

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path('fixtures', __dir__)
  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
  ActiveSupport::TestCase.file_fixture_path = "#{ActiveSupport::TestCase.fixture_path}/files"
  ActiveSupport::TestCase.fixtures :all
end

module ActiveSupport
  class TestCase
    teardown { SmsTrap.store.clear }

    # Temporarily overrides SmsTrap.reply_handler for the duration of the block, restoring
    # whatever was configured before (e.g. the dummy app's initializer) afterward.
    def with_reply_handler(handler)
      original = SmsTrap.instance_variable_get(:@reply_handler)
      SmsTrap.reply_handler = handler
      yield
    ensure
      SmsTrap.instance_variable_set(:@reply_handler, original)
    end
  end
end
