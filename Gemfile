# YourPlatform
gem 'your_platform', path: 'your_platform'

source 'https://rubygems.org' do
  gem 'rails', '~> 7.1'
  gem 'pg', '>= 1.5'
  gem 'sassc-rails' # ruby-sass is EOL; libsass via sassc
  gem 'terser' # uglifier is abandoned and fails on ES6
  gem 'coffee-rails', '>= 4.0.0'
  gem 'turbolinks'

  gem 'puma'

  # Spring speeds up development by keeping your application running in the background.
  group :development do
    gem 'spring'
    gem 'spring-commands-rspec'
  end

  # Error tracing
  group :development do
    #gem 'better_errors'
    gem 'binding_of_caller'
    gem 'letter_opener'
    gem 'letter_opener_web'
    gem 'pry-remote'
    gem 'web-console'
  end

  group :test, :development do
    gem 'pry'
  end

  # Security Tools
  group :development, :test do
    gem 'brakeman', '>= 2.3.1'
  end

  # Documentation Tools
  group :development, :test do
    gem 'yard'
    gem 'redcarpet'
  end

  # Testing Environment
  group :test, :development do
    gem 'rspec-rails'
    gem 'rspec-collection_matchers'
    gem 'rspec-its'
    gem 'parallel_tests'
    gem 'rspec-instafail'
    gem 'rspec-retry'
    gem 'capybara', '~> 3.0'
    gem 'selenium-webdriver', '~> 4.0'
    gem 'factory_bot_rails'
    gem 'database_cleaner'
    gem 'email_spec'
    gem 'timecop'
    gem 'guard'
    gem 'guard-rspec'
  end

  # JavaScript Runtime
  gem 'execjs'
  gem 'mini_racer'

  # Other helpers
  gem 'json'
  gem 'colored'

  # Security fixes
  gem 'rubyzip', '>= 1.2.1'  # CVE-2017-5946
  gem 'nokogiri', '>= 1.7.1'  #  USN-3235-1

  # Temporary pins during the rails upgrade
  # (https://github.com/fiedl/wingolfsplattform/issues/126):
  # bumping the engine gemspec unlocks all engine dependencies in the
  # lockfile, and bundler would jump these to new majors mid-upgrade.
  # The JS-facing gems must not move at all (frozen JS stack); the API
  # clients and formatters stay on their pre-upgrade majors until after
  # the rails hops. Remove pin by pin once the upgrade has landed.
  gem 'i18n-js', '~> 3.8.0'
  gem 'chartkick', '~> 3.4.2'
  gem 'discourse_api', '~> 0.45.0'
  gem 'merit', '~> 4.0.1'
  gem 'gemoji', '~> 3.0.1'
  gem 'reverse_markdown', '~> 2.0.0'
  gem 'biggs', '~> 0.3.3'
  gem 'faraday', '~> 1.3'

  # Temporary Forks and Overrides
  # refile is vendored (from the sobrinho fork) with rest-client
  # relaxed: ~> 1.8 pinned mime-types below 3, which is a SyntaxError
  # on ruby 3. The ActiveStorage migration retires it eventually.
  gem 'refile', path: 'vendor/gems/refile'
  gem 'refile-mini_magick', git: 'https://github.com/refile/refile-mini_magick'

  # To customly set timeout time we need rack-timeout
  gem 'rack-timeout'

  # Profiling
  gem 'flamegraph'
  gem 'stackprof'

  # New relic profiling
  # gem 'newrelic_rpm'

  # Maintenance Mode
  gem 'turnout'

  # Entity relationship diagrams
  gem 'rails-erd', require: false, group: :development

end

ruby '~> 3.1.0'
