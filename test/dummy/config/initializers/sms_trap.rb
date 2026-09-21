# frozen_string_literal: true

# Stand-in for wherever a real host app wires SmsTrap.reply_handler to its real inbound
# webhook path. The dummy app has no such path, so this just logs.
SmsTrap.reply_handler = lambda do |from:, to:, text:|
  Rails.logger.info("[dummy] simulated inbound reply from #{from} to #{to}: #{text}")
end
