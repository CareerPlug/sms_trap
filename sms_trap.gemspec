# frozen_string_literal: true

require_relative 'lib/sms_trap/version'

Gem::Specification.new do |spec|
  spec.name        = 'sms_trap'
  spec.version     = SmsTrap::VERSION
  spec.authors     = ['Ross Reinhardt']
  spec.email       = ['rreinhardt9@gmail.com']
  spec.homepage    = 'https://github.com/CareerPlug/sms_trap'
  spec.summary     = 'A local SMS interception and viewing UI for development — Mailtrap for SMS.'
  spec.description = 'SmsTrap intercepts outbound SMS sends in development so nothing ever reaches a real ' \
                     'phone, and shows them in a phone-styled browser UI. It ships a provider-agnostic ' \
                     'test connector that any host app can point its SMS delivery layer at.'
  spec.license     = 'MIT'
  spec.required_ruby_version = '>= 3.1'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  end

  spec.add_dependency 'rails', '>= 7.0.10'
end
