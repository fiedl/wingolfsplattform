require_relative 'boot'

require 'rails/all'

# Determine a possible staging environment.
::STAGE = if __FILE__.start_with?('/var/')
  # wingolfsplattform, wingolfsplattform-master, wingolfsplattform-sandbox
  __FILE__.split('/')[2]
else
  Rails.env.to_s + ENV['TEST_ENV_NUMBER'].to_s
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Wingolfsplattform
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
