require 'exception_notification/rails'
require 'exception_notification/sidekiq'

ExceptionNotification.configure do |config|
  # Ignore additional exception types.
  # ActiveRecord::RecordNotFound, AbstractController::ActionNotFound and ActionController::RoutingError are already added.
  config.ignored_exceptions += %w{ActionController::MissingFile CanCan::AccessDenied}

  # Adds a condition to decide when an exception must be ignored or not.
  # The ignore_if method can be invoked multiple times to add extra conditions.
  # config.ignore_if do |exception, options|
  #   not Rails.env.production?
  # end

  # Notifiers =================================================================

  # Email notifier sends notifications by email.
  # config.add_notifier :email, {
  #   :email_prefix            => "[ERROR] ",
  #   :sender_address => %{"Error notification" <noreply@example.org>},
  #   :exception_recipients    => %w{support@example.org},
  # }

  # Custom ticket system via email.
  config.add_notifier :ticket_system, {
    :email_prefix            => "[ERROR] ",
    :fallback_sender_address => %{"Plattform-Fehler" <noreply@wingolf.io>},
    :exception_recipients    => ["fehler.wingolf.io@fiedlschuster.de"],
    :sections                => %w(request current_user session environment backtrace)
  }

  # Campfire notifier sends notifications to your Campfire room. Requires 'tinder' gem.
  # config.add_notifier :campfire, {
  #   :subdomain => 'my_subdomain',
  #   :token => 'my_token',
  #   :room_name => 'my_room'
  # }

  # HipChat notifier sends notifications to your HipChat room. Requires 'hipchat' gem.
  # config.add_notifier :hipchat, {
  #   :api_token => 'my_token',
  #   :room_name => 'my_room'
  # }

  # Webhook notifier sends notifications over HTTP protocol. Requires 'httparty' gem.
  # config.add_notifier :webhook, {
  #   :url => 'http://example.com:5555/hubot/path',
  #   :http_method => :post
  # }

end
