Wingolfsplattform::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false
  
  # Eager loading behaviour has to be set in rails 4.
  config.eager_load = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Expands the lines which load the assets
  # When set to false, compiled assets would be used in development.
  config.assets.debug = true


  # Plugin Reload
  # see: http://stackoverflow.com/questions/5156061/reopening-rails-3-engine-classes-from-parent-app
  # This is to be able to re-open engine classes.
  config.reload_plugins = true


  # Mailer Settings
  config.action_mailer.delivery_method = :sendmail
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000, protocol: 'https' }

end
