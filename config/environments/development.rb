Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  config.action_controller.perform_caching = true
  # The cache store is configured centrally in the engine's
  # config/initializers/cache.rb (redis via REDIS_HOST). Anything set
  # here would be overridden there.

  # Mailing
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = {host: 'wingolf.io', protocol: 'https'}
  config.action_mailer.default_options = {from: 'Wingolfsplattform <wingolfsplattform@wingolf.io>'} # See: http://stackoverflow.com/a/12609856/2066546

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Simulate asset stuff to mimic production.
  if ENV['SIMULATE_PRODUCTION']
    config.assets.js_compressor = :uglifier
    config.assets.css_compressor = :sass
    config.assets.compile = false
    config.assets.digest = true
    config.assets.debug = false
    config.public_file_server.enabled = true
  end

end
