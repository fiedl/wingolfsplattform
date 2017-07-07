# YourPlatform
gem 'your_platform', git: 'https://github.com/fiedl/your_platform', branch: 'sf/wingolf-org-with-caching'

source 'https://rubygems.org' do
  # Ruby License, http://www.ruby-lang.org/en/LICENSE.txt
  gem 'rails', '~> 4.2.1'	 # MIT License

  gem 'mysql2'	# MIT License
  gem 'transaction_retry' # rescue from deadlocks

  gem 'sass-rails', '>= 4.0.3'
  gem 'uglifier', '>= 1.3.0'  # MIT License
  gem 'coffee-rails', '>= 4.0.0'

  # See https://github.com/sstephenson/execjs#readme for more
  # supported runtimes.
  # This is also needed by twitter-bootstrap-rails in production.
  gem 'execjs'
  # But therubyracer apparently uses a lot of memory:
  # https://github.com/seyhunak/twitter-bootstrap-rails/issues/336
  gem 'therubyracer', :platform => :ruby

  # To use Jbuilder templates for JSON
  # gem 'jbuilder'

  # Use unicorn as the app server
  gem 'unicorn'

  # RAILS-3-MIGRATION TEMPORARY GEMS, TODO: REMOVE THOSE
  gem 'activesupport-json_encoder'

  # Deploy with Capistrano
  # gem 'capistrano'

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
    gem 'rspec-legacy_formatters'
    gem 'rspec-instafail'
    gem 'rspec-its'
    gem 'guard-rspec'
    gem 'rspec-rerun'
    gem 'parallel_tests'
  #  gem 'rspec-mocks'
  #  gem 'listen'
  #  gem 'rb-inotify', '0.8.8' if RUBY_PLATFORM.downcase.include?("linux")
  end
  group :test do
    gem 'capybara'
    gem 'launchy'
    gem 'factory_girl_rails', '>= 4.0.0' # '1.4.0'
    gem 'database_cleaner'
    gem 'email_spec'
    gem 'timecop'  # time_travel
    gem 'fuubar' # better progress bar for specs
    gem 'poltergeist'
    gem 'selenium-webdriver'
  end
  group :development do
    gem 'spring'
    gem 'spring-commands-rspec'
  end

  # Pry Console Addon
  gem 'pry', group: :development
  gem 'pry-remote', group: :development

  # Receiving Mails
  gem 'mailman', require: false
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

  # To customly set timeout time we need rack-timeout
  gem 'rack-timeout'

  # Metrics
  gem 'browser', '1.1.0'

  # Profiling
  gem 'flamegraph'
  gem 'stackprof'

  # Temporary Dependency Resolving
  # TODO Remove when obsolete
  gem 'tilt', '~> 1.4.1'

  # Maintenance Mode
  gem 'turnout'

  gem 'newrelic_rpm'
  #gem 'jquery-datatables-rails', git: 'git://github.com/rweng/jquery-datatables-rails.git'

  # get emails for exceptions.
  # http://railscasts.com/episodes/104
  gem 'exception_notification'

  #gem 'bootstrap', git: 'https://github.com/twbs/bootstrap-rubygem'

  gem 'sidekiq', '~> 3.5.1'

  # Temporary fixes
  gem 'gemoji', '~> 2.1.0'
  gem 'haml', '~> 4.0'

  # Security Fixes
  gem 'rubyzip', '>= 1.2.1'  # CVE-2017-5946
  gem 'nokogiri', '>= 1.7.1'  #  USN-3235-1
end

source 'https://rails-assets.org'
#source 'https://rails-assets.org' do
#  gem 'rails-assets-tether', '>= 1.1.0'
#end

ruby '2.3.3'
