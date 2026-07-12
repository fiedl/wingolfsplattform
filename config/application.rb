require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Wingolfsplattform
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Serialized columns (pages.redirect_to, pages.box_configuration,
    # settings.value) hold more than plain strings; rails >= 5.2.8.1
    # rejects these classes in YAML columns unless listed
    # (CVE-2022-32224).
    config.active_record.yaml_column_permitted_classes = [
      Symbol, Date, Time, DateTime, BigDecimal,
      ActiveSupport::TimeWithZone, ActiveSupport::TimeZone,
      ActiveSupport::Duration,
      ActiveSupport::HashWithIndifferentAccess,
    ]
  end
end
