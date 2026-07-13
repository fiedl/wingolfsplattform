$:.push File.expand_path("../lib", __FILE__)

# SEE ALSO
# https://github.com/fiedl/your_platform/blob/master/your_platform.gemspec

# Maintain your gem's version:
require "your_platform/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "your_platform"
  s.version     = YourPlatform::VERSION

  s.authors     = [ "Sebastian Fiedlschuster" ]
  s.email       = [ "sebastian@fiedlschuster.de" ]
  s.homepage    = "https://github.com/fiedl/your_platform"

  s.summary     = "Administrative and social network platform for closed user groups."
  s.description = s.summary

  s.files = Dir["{app,config,db,lib,vendor}/**/*"] + ["README.md"]
  s.test_files = Dir["spec/**/*"]

  #
  # Dependencies
  #

  # Rails and Rails Additions
  s.add_dependency "rails", "~> 7.1.0"
  s.add_dependency 'rack', '>= 1.6.2'
  s.add_dependency "rails-i18n"                                                        # MIT License
  s.add_dependency "responders", "~> 3.0"
  s.add_dependency "bundler", ">= 1.9.4"
  s.add_development_dependency 'web-console'
  s.add_dependency 'sprockets-rails', '>= 2.3.2' # required by bootstrap
  s.add_dependency 'decent_exposure'


  # JavaScript
  s.add_dependency 'jquery-rails'
  s.add_dependency "sugar-rails"
  s.add_dependency "i18n-js", '>= 3.0.0.rc8'
  s.add_dependency "coffee-rails", '>= 4.1.0'
  s.add_dependency 'execjs', '>= 2.5.2'
  s.add_dependency 'json', '~> 2.3.0'

  # Data Structures
  # The DAG structure lives in lib/your_platform/dag, vendored from
  # https://github.com/fiedl/acts-as-dag (branch sf/rails-5).
  s.add_dependency 'acts_as_tree'                                                      # MIT License
  s.add_dependency 'wannabe_bool'
  s.add_dependency 'acts-as-taggable-on', '>= 7.0'

  # Caching (rails' redis_cache_store; redis-namespace only for sidekiq)
  s.add_dependency 'redis', '>= 4.0.1' # required by redis_cache_store
  s.add_dependency 'redis-namespace'

  # Workers
  s.add_dependency 'foreman'
  # sidekiq 4 pins redis < 4, which redis_cache_store needs; 6 is the
  # newest major that still runs the custom fetch strategy with minor
  # adaptions and supports rails 5.2 through 6.x.
  s.add_dependency 'sidekiq', '~> 6.0'

  # Authentification
  # rails 6 requires >= 4.7; devise 5 requires rails >= 6.1 — widen at
  # the rails 6.1 hop.
  s.add_dependency 'devise', '~> 4.7'
  #s.add_dependency 'omniauth-github'
  #s.add_dependency 'omniauth-twitter'
  #s.add_dependency 'omniauth-google-oauth2'
  #s.add_dependency 'omniauth-facebook', '~> 3.0.0'
  # omniauth dropped due to CVE-2015-9284
  # https://github.com/fiedl/your_platform/network/alert/demo_app/my_platform/Gemfile.lock/omniauth/open
  # https://github.com/omniauth/omniauth/issues/960
  # https://github.com/omniauth/omniauth/pull/809

  s.add_dependency 'devise_masquerade', '~> 0.5.3'
  s.add_dependency 'gender_detector'
  # The former = 1.1.0 pin guarded an authenticate_api_v1_user_account!
  # regression in 1.1.1 (trello c/p7kSJGz5); retested per the upgrade
  # plan, https://github.com/fiedl/wingolfsplattform/issues/126.
  s.add_dependency 'devise_token_auth', '~> 1.2'
  s.add_dependency 'rack-cors'

  # Authorization
  # 1.15's accessible_by built OR chains with broken bind parameters on
  # rails 5.2 (PG::ProtocolViolation on the group members page).
  s.add_dependency 'cancancan', '~> 3.0'

  # To use ActiveModel has_secure_password (password encryption)
  s.add_dependency 'bcrypt', '>= 3.0.1'                                                # MIT License

  # Settings: vendored in lib/rails_settings (formerly the
  # rails-settings-cached gem, whose 2.x line dropped object-scoped
  # settings; the settings table holds production data).

  # Template Engines
  # haml 4 references the Erubis template handler that rails 5.2 removed.
  # (The precompiled_method_return_value NameError that once blocked
  # haml 5 — see bad4932c — did not reproduce on rails 5.2 with haml 5.2.)
  s.add_dependency 'haml', '~> 5.0'
  s.add_dependency 'redcarpet', '>= 3.3.2'  # for Markdown                             # MIT License
  s.add_dependency 'gemoji', '>= 2.1.0'
  s.add_dependency 'auto_html', '~> 1.6.4'
  s.add_dependency 'reverse_markdown'

  s.add_dependency 'sassc-rails' # ruby-sass is EOL; libsass via sassc

  # Search
  s.add_dependency 'elasticsearch-model'

  # Geo Coding
  s.add_dependency 'geocoder'                                                          # MIT License
  s.add_dependency 'biggs'

  # Form Helper
  s.add_dependency 'formtastic'  # MIT License
  s.add_dependency 'simple_form', '>= 5.0.0' # GHSA-r74q-gxcg-73hx, https://trello.com/c/rX2RZtgU/1438

  # File Uploads
  # Store paths are unchanged by the bump: the uploader defines an
  # absolute store_dir, and production uploads exist there.
  # 1.x, not 2.x: carrierwave 2 needs image_processing >= 1.1, which
  # refile-mini_magick caps below 1.0 — revisit with the refile ->
  # ActiveStorage migration.
  s.add_dependency 'carrierwave', '~> 1.3'
  # 4.x line: carrierwave 1.3 drives the mini_magick 4 api
  # (combine_options is gone in 5). 4.11+ is ruby-3 clean.
  s.add_dependency 'mini_magick', '~> 4.11'
  s.add_dependency 'refile', '>= 0.5.5'
  s.add_dependency 'rest-client', '>= 1.8'

  # View Helpers
  s.add_dependency 'phony'
  s.add_dependency 'naturally' # natural sorting 1, 3, 12

  # Client-Side Validations
  s.add_dependency 'judge'

  # Metrics
  s.add_dependency 'rack-mini-profiler'
  s.add_dependency 'chartkick', '>= 3.2.0' # CVE-2019-12732
  s.add_dependency 'groupdate'
  s.add_dependency 'impressionist', '>= 1.6' # 1.6 breaks on rails 7 engine load hooks

  # Activity Feed
  s.add_dependency 'public_activity', '~> 1.4.1'                                       # MIT License

  # XLS Export
  s.add_dependency 'to_xls'
  s.add_dependency 'excelinator'

  # PDF Export
  s.add_dependency 'prawn', '2.0.2' # 2.1.0 breaks layout margins

  # ICS Export (iCal)
  s.add_dependency 'icalendar'

  # VCF Export
  s.add_dependency 'vcardigan'

  # XML Export
  s.add_dependency 'sepa_king'

  # Gamification
  s.add_dependency 'merit'

  # Dummy Data Generation
  s.add_dependency 'faker', '~> 2.3'

  # Console
  s.add_dependency "table-formatter"

  # Contact form
  s.add_dependency 'mail_form'

  # API
  s.add_dependency 'apipie-rails', '~> 0.5'
  s.add_dependency 'discourse_api'

  # Exceptions
  s.add_dependency 'exception_notification'

  # Log
  s.add_dependency 'fiedl-log'

  # LDAP
  s.add_dependency 'net-ldap'

  # Trello API
  s.add_dependency 'ruby-trello'

  # Emails and Encoding
  s.add_dependency 'charlock_holmes'
  s.add_dependency 'extended_email_reply_parser'


  # Fixes
  # https://github.com/eventmachine/eventmachine/issues/509
  s.add_dependency 'eventmachine', '>= 1.0.7'
  s.add_dependency 'terser' # uglifier is abandoned and fails on ES6
  s.add_dependency 'mail', '~> 2.8' # 2.6.6 crashed on nil Sender, https://github.com/fiedl/wingolfsplattform/issues/109
  s.add_dependency 'nokogiri', '>= 1.10.4' # CVE-2019-5477, https://trello.com/c/whoVKwMA/1394
  s.add_dependency 'actionpack', '>= 4.2.5.2' # CVE-2016-2098, https://gemnasium.com/fiedl/your_platform/alerts#advisory_342
  s.add_dependency 'activerecord', '>= 4.2.7.1' # CVE-2016-6317, https://gemnasium.com/github.com/fiedl/your_platform/alerts#advisory_426
  s.add_dependency 'rubyzip', '>= 1.3.0'  # CVE-2019-16892, https://trello.com/c/2dzbwn2f/1439
  s.add_dependency 'actionview', '>= 5.0.7.2'  # CVE-2019-5418, https://trello.com/c/4sVtIW7h/1330-kritische-sicherheitslücke-in-actionview-cve-2019-5418
  s.add_dependency 'yard', '>= 0.9.20' # GHSA-xfhh-rx56-rxcr

  #
  # Development Dependencies
  #

  s.add_development_dependency "rspec-rails"

  # Email preview
  s.add_development_dependency "letter_opener"
  s.add_development_dependency "letter_opener_web"

end
