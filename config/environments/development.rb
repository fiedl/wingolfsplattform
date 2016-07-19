Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  config.eager_load = false

  # Show full error reports
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true  # default: false
  #config.cache_store = :file_store, Rails.root.join("tmp/app_cache")
  config.cache_store = :redis_store, 'redis://redis:6379/0/', { expires_in: 1.day, namespace: 'development_cache' }

  # Care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Raises error for missing translations
  config.action_view.raise_on_missing_translations = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  config.asset_host = "http://localhost:3000"


  # Plugin Reload
  # see: http://stackoverflow.com/questions/5156061/reopening-rails-3-engine-classes-from-parent-app
  # This is to be able to re-open engine classes.
  config.reload_plugins = true


  # Mailer Settings
  config.action_mailer.delivery_method = :letter_opener
  # config.action_mailer.delivery_method = :sendmail
  # config.action_mailer.delivery_method = :smtp
  # config.action_mailer.smtp_settings = {
  #   address: 'smtp.1und1.de',
  #   user_name: 'wingolfsplattform@wingolf.org',
  #   password: '',
  #   domain: 'wingolfsplattform.org',
  #   enable_starttls_auto: true
  # }
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000, protocol: 'http' }

  # See: http://stackoverflow.com/a/12609856/2066546
  config.action_mailer.default_options = {
    from: 'Wingolfsplattform <wingolfsplattform@wingolf.org>'
  }


end
