source 'https://rubygems.org'  # Ruby License, http://www.ruby-lang.org/en/LICENSE.txt

gem 'rails', '~> 4.1.7'		# MIT License

gem 'mysql2'	# MIT License
gem 'transaction_retry' # rescue from deadlocks

gem 'coffee-rails'
gem 'uglifier', '>= 1.0.3'						# MIT License


# See https://github.com/sstephenson/execjs#readme for more
# supported runtimes.
# This is also needed by twitter-bootstrap-rails in production.
gem 'execjs'
# But therubyracer apparently uses a lot of memory:
# https://github.com/seyhunak/twitter-bootstrap-rails/issues/336
gem 'therubyracer', :platform => :ruby

gem 'jquery-rails'							# MIT License

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# HTML-Nodes
gem 'nokogiri'								# MIT License

# DAG für Nodes Model, see: https://github.com/resgraph/acts-as-dag
#gem 'acts-as-dag', path: '../acts-as-dag'
#gem 'acts-as-dag', git: "git://github.com/resgraph/acts-as-dag.git"	# MIT License
#gem 'acts-as-dag', '>= 2.5.7'  # now in your_platform


# JSON
gem 'json'								# Ruby License

# Lucene
# gem 'lucene'								# MIT License

# Farbiger Konsolen-Output
gem 'colored'								# MIT License

# Auto Completion
#gem 'rails3-jquery-autocomplete'					# MIT Licenses

# Debug Tools
group :development do

  # debugger: http://guides.rubyonrails.org/debugging_rails_applications.html
  #gem 'debugger'

  gem 'better_errors'              # see Railscasts #402
  gem 'binding_of_caller'
  gem 'meta_request'
  
  gem 'letter_opener'
end

# Security Tools
group :development, :test do
  gem 'brakeman', '>= 2.3.1'
  gem 'guard-brakeman', '>= 0.8.1'
end

# Documentation Tools
group :development, :test do
  gem 'yard'
  gem 'redcarpet'
end

# RSpec, see: http://ruby.railstutorial.org/chapters/static-pages#sec:first_tests
group :test, :development do
  gem 'guard', '~> 2.2.5'
  gem 'guard-focus'
  gem 'rspec-rails'
  gem 'guard-rspec'
  gem 'rspec-rerun', github: 'dblock/rspec-rerun'
#  gem 'rspec-mocks'
#  gem 'listen'
#  gem 'rb-inotify', '0.8.8' if RUBY_PLATFORM.downcase.include?("linux")
end
group :test do
  gem 'capybara'
  gem 'launchy'
  gem 'factory_girl_rails', '>= 4.0.0' # '1.4.0'
  gem 'database_cleaner'
  gem 'guard-spork'
  gem 'spork'
  gem 'simplecov', require: false
  gem 'email_spec'
  gem 'timecop'  # time_travel
  gem 'fuubar' # better progress bar for specs
  gem "codeclimate-test-reporter", require: nil
end

group :test do
  gem 'poltergeist', '1.5.0'
end

# Pry Console Addon
gem 'pry', group: :development

# Turbolinks
gem 'turbolinks', '>= 1.0'

# Angular JS
gem 'angularjs-rails'

# Receiving Mails
gem 'mailman', require: false
gem 'mail', git: 'git://github.com/jeremy/mail.git'
# gem 'rb-inotify', '~> 0.9', group: :production
  # https://github.com/fiedl/wingolfsplattform/commit/2dafbda71af2bed2be46c79b558cbff8548b0df2
  # Removed rb-inotify due to asset compilation issues after updating to rails 3.2.21.


# View Helpers
# gem 'rails-gallery', git: 'https://github.com/kristianmandrup/rails-gallery'

# Encoding Detection
gem 'charlock_holmes'

# readline (for rails console)
# see https://github.com/luislavena/rb-readline/issues/84#issuecomment-17335885
#gem 'rb-readline', '~> 0.5.0', group: :development, require: 'readline'

gem 'gmaps4rails', '~> 2.0.1', git: 'git://github.com/fiedl/Google-Maps-for-Rails.git'

# To customly set timeout time we need rack-timeout
gem 'rack-timeout'

# Metrics
gem 'fnordmetric'

# Profiling
gem 'rack-mini-profiler'
gem 'flamegraph'

# Code Coverage Badge, coveralls.io
gem 'coveralls', require: false

# Temporary Dependency Resolving
# TODO Remove when obsolete
gem 'tilt', '~> 1.4.1'

# Maintenance Mode
gem 'turnout'

# Sidekiq Error Web UI
gem 'sidekiq-failures'

gem 'newrelic_rpm'
#gem 'jquery-datatables-rails', git: 'git://github.com/rweng/jquery-datatables-rails.git'
gem 'prawn', github: 'prawnpdf/prawn'

gem 'formtastic', '~> 2.2.1'

# YourPlatform
gem 'your_platform', github: 'fiedl/your_platform', branch: 'rails4'
