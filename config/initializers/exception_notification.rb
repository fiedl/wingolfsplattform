Rails.application.config.middleware.use ExceptionNotification::Rack, {
  ignore_exceptions: ExceptionNotifier.ignored_exceptions + [],
  :email => {
    :email_prefix => "[ERROR] ",
    :sender_address => %{"Plattform-Fehler" <noreply@wingolfsplattform.org>},
    :exception_recipients => %w{root@wingolfsplattform.org},
    :sections => %w(request current_user session environment backtrace)
  }
}