require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# The impressionist engine includes ImpressionistController into
# ActionController via an on_load hook, but leaves the module to
# autoloading — which rails 7 forbids at that point. Require it
# explicitly before action_controller loads.
require Gem.loaded_specs['impressionist'].full_gem_path + '/app/controllers/impressionist_controller.rb'

module Wingolfsplattform
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Enqueue jobs immediately, as before rails 7.2: the cache-renewal
    # jobs run inline in the test suite, whose transactional examples
    # never commit — deferring until commit would silently skip them.
    # (The renewal jobs are idempotent; deferred enqueue buys nothing
    # here.)
    config.active_job.enqueue_after_transaction_commit = :never if Rails.version >= "7.2"

    # App secrets, formerly config/secrets.yml: Rails.application.secrets
    # is removed in rails 7.2. Values come from the environment; the yml
    # provides known dummy fallbacks for development and test.
    config.app_secrets = config_for(:app_secrets)
    config.secret_key_base = config.app_secrets.secret_key_base

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
