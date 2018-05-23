# YourPlatform
gem 'your_platform', git: 'https://github.com/fiedl/your_platform', branch: 'master'

source 'https://rubygems.org' do
  gem 'rails', '~> 5.0'
  gem 'mysql2'
  gem 'sass-rails'
  gem 'uglifier', '>= 1.3.0'
  gem 'coffee-rails', '>= 4.0.0'
  gem 'turbolinks'

  gem 'puma'

  group :production do
    gem 'unicorn'
  end

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
    gem 'capybara'
    gem 'selenium-webdriver'
    gem 'poltergeist'
    gem 'factory_girl_rails'
    gem 'database_cleaner'
    gem 'email_spec'
    gem 'timecop'
  end

  # JavaScript Runtime
  gem 'execjs'
  gem 'therubyracer', :platform => :ruby

  # Other helpers
  gem 'json'
  gem 'colored'

  # Security fixes
  gem 'rubyzip', '>= 1.2.1'  # CVE-2017-5946
  gem 'nokogiri', '>= 1.7.1'  #  USN-3235-1

  # Temporary Forks and Overrides
  gem 'acts-as-dag', git: 'https://github.com/fiedl/acts-as-dag', branch: 'sf/rails-5'
  gem 'refile', git: 'https://github.com/sobrinho/refile'
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

source 'https://rails-assets.org'
#source 'https://rails-assets.org' do
#  gem 'rails-assets-tether', '>= 1.1.0'
#end

ruby '2.3.3'
