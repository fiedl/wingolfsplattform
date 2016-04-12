require File.expand_path('../boot', __FILE__)

require 'csv'
require 'colored'

# Pick the frameworks you want:
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Raise an error if the config/secrets.yml file does not exist.
# In production, this file is provided by our ops scripts.
# In development, the developer may copy the file
# config/secrets.example.yml.
if not File.exist?(File.expand_path('../secrets.yml', __FILE__))
  print "Please create the file config/secrets.yml.\n\n".blue
  print "If you are in development, copy the config/secrets.example.yml\n".bold
  print "to config/secrets.yml and set a secret_key_base there.\n\n".bold
  print "Suggestions:\n"
  print "  cp config/secrets.example.yml config/secrets.yml\n".green
  print "  pwgen 100".green
  print "  # to generate the secret_key_base. Put it into the config/secrets.yml.\n\n"
  print "More Info:\n"
  print "  * http://guides.rubyonrails.org/upgrading_ruby_on_rails.html#action-pack\n"
  print "  * http://guides.rubyonrails.org/4_1_release_notes.html#config-secrets-yml\n"
  print "  * https://trello.com/c/Dlio0wG9/281-rails-4\n\n"
  raise 'The file config/secrets.yml does not exist.'
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

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
    
    # fix for field_with_errors in form helper, see: http://www.rabbitcreative.com/2010/09/20/rails-3-still-fucking-up-field_with_errors/
    config.action_view.field_error_proc = Proc.new { |html_tag, instance| "<span class=\"field_with_errors\">#{html_tag}</span>".html_safe }


    # Exceptions: Use own app as exception handler.
    # http://railscasts.com/episodes/53-handling-exceptions-revised
    config.exceptions_app = self.routes if Rails.env.production?
  end
end

# $enable_tracing = false
# $trace_out = open('trace.txt', 'w')
# 
# set_trace_func proc { |event, file, line, id, binding, classname|
#   if $enable_tracing && event == 'call'
#     $trace_out.puts "#{file}:#{line} #{classname}##{id}"
#   end
# }
# 
# $enable_tracing = true
