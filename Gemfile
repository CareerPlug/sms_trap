# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in sms_trap.gemspec.
gemspec

gem 'puma'

gem 'sqlite3'

gem 'sprockets-rails'

# json 3.x dropped the `quirks_mode:` keyword that activesupport 7.2's JSON encoder still
# passes to JSON.generate, breaking session cookie serialization. Pin to the 2.x series.
gem 'json', '~> 2.9'

group :development do
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
end

# Start debugger with binding.b [https://github.com/ruby/debug]
# gem "debug", ">= 1.0.0"
