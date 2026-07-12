# YourPlatform
gem 'your_platform', path: 'your_platform'

source 'https://rubygems.org' do
  gem 'rails', '~> 5.0'
  # pg 1.2 removed the PGconn constant that rails 5.0's postgresql
  # adapter still uses. Lift this pin during the rails upgrade.
  gem 'pg', '~> 1.1.4'
  gem 'sass-rails'
  gem 'uglifier', '>= 1.3.0'
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
    # Pin: factory_bot 6.3+ requires ruby 3, but the old bundler ignores
    # the gem's required_ruby_version.
    gem 'factory_bot_rails', '~> 6.2.0'
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
  gem 'redis-rack', '~> 2.1'
  # actionview 5.1 dropped erubis for erubi, but haml 4 still requires
  # erubis. Drop together with the haml 5 bump.
  gem 'erubis'

  # Temporary Forks and Overrides
  gem 'refile', git: 'https://github.com/sobrinho/refile'
  gem 'refile-mini_magick', git: 'https://github.com/refile/refile-mini_magick'
  gem 'rails-settings-cached', '0.7.1'
  gem 'mimemagic', '~> 0.3.10' # TODO: remove when updating to rails 5.2, https://github.com/rails/rails/issues/41750

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

ruby '2.7.1'
