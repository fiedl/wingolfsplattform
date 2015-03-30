require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'csv'


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
#Bundler.require(:default, Rails.env)

# config/secrets.yml
require 'yaml'
secrets_file = File.expand_path('../secrets.yml', __FILE__)
if File.exists?(secrets_file)
  ::SECRETS = YAML.load(File.read(secrets_file)) 
else
  ::SECRETS = {}
end

# Determine a possible staging environment.
#
if __FILE__.start_with?('/var/')
  ::STAGE = __FILE__.split('/')[2] # ['wingolfsplattform', 'wingolfsplattform-master', 'wingolfsplattform-sandbox']
else
  ::STAGE = Rails.env.to_s
end

module Wingolfsplattform
  class Application < Rails::Application
    
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.enforce_available_locales = true
    I18n.config.enforce_available_locales = true
    config.i18n.load_path = Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s] + config.i18n.load_path
    config.i18n.available_locales = [:de, :en]
    config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql
    
    # # If assets do not refresh properly using sass in development, use this.
    # # http://www.tkalin.com/blog_posts/rails-4-disable-assets-caching-for-development-test-environments/
    # #
    # # Use memory store for assets cache in development/test to avoid caching
    # # to tmp/assets, because it causes hiding of deprecation messages in
    # # stylesheets, sometimes break parallel_tests and doesn't always refresh
    # # gem stylesheets in development
    # #
    # config.assets.configure do |env|
    #   if Rails.env.development? || Rails.env.test?
    #     env.cache = ActiveSupport::Cache.lookup_store(:memory_store)
    #   end
    # end

    # fix for field_with_errors in form helper, see: http://www.rabbitcreative.com/2010/09/20/rails-3-still-fucking-up-field_with_errors/
    config.action_view.field_error_proc = Proc.new { |html_tag, instance| "<span class=\"field_with_errors\">#{html_tag}</span>".html_safe }


    # Exceptions: Use own app as exception handler.
    # http://railscasts.com/episodes/53-handling-exceptions-revised
    config.exceptions_app = self.routes if Rails.env.production?
    
  end

end

