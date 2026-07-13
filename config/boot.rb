ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

# Before rails: concurrent-ruby >= 1.3.5 no longer requires 'logger',
# which activesupport < 7.1 relied on transitively
# (uninitialized constant ActiveSupport::LoggerThreadSafeLevel::Logger).
require 'logger'

require 'bundler/setup' # Set up gems listed in the Gemfile.
