Rails.application.config.middleware.use ExceptionNotification::Rack, {
  ignore_exceptions: ExceptionNotifier.ignored_exceptions + [ActionController::MissingFile],
  :ticket_system => {
    :email_prefix => "[ERROR] ",
    :fallback_sender_address => %{"Plattform-Fehler" <noreply@wingolfsplattform.org>},
    :exception_recipients => %w{support@wingolf.org},
    :sections => %w(request current_user session environment backtrace)
  }
}