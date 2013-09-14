# -*- coding: utf-8 -*-

                                                                                           # Licenses
                                                                                           # =======================================

source 'https://rubygems.org'						                                                   # Ruby License,
                                                                                           # http://www.ruby-lang.org/en/LICENSE.txt



gem 'rails', '~> 3.2.11'						# MIT License,
    	     								# http://www.opensource.org/licenses/mit-license.php

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'mysql2'								# MIT License

# Gems used only for assets and not required
# in production environments by default.
group :assets, :production, 'testing-aki' do
  gem 'sass-rails',   '~> 3.2.3'					# MIT License
  gem 'coffee-rails', '~> 3.2.1'					# MIT License
#  gem 'coffee-script', '1.4.0' # need this at 1.4.0 for mercury, at the moment
    # see https://github.com/jejacks0n/mercury/issues/349

  gem 'uglifier', '>= 1.0.3'						# MIT License

end

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

# GoogleMaps
# moved dependency to your_platform.
# for turbolinks experiments, use this:
#   gem 'gmaps4rails', '>= 2.0.0.pre', git: 'https://github.com/fiedl/Google-Maps-for-Rails.git'

# jQuery UI
gem 'jquery-ui-rails'							# dual: MIT License, GPL2 License 

# DAG für Nodes Model, see: https://github.com/resgraph/acts-as-dag
#gem 'acts-as-dag', path: '../acts-as-dag'
#gem 'acts-as-dag', git: "git://github.com/resgraph/acts-as-dag.git"	# MIT License
#gem 'acts-as-dag', '>= 2.5.7'  # now in your_platform

# Formtastic Form Helper, 
# see: https://github.com/justinfrench/formtastic, 
# http://rubydoc.info/gems/formtastic/frames
gem 'formtastic'							# MIT License

# JSON
gem 'json'								# Ruby License

# Lucene
# gem 'lucene'								# MIT License

# Farbiger Konsolen-Output					
gem 'colored'								# MIT License

# Auto Completion
#gem 'rails3-jquery-autocomplete'					# MIT Licenses

# Deployment with Capistrano.
# Capistrano runs locally, not on the remote server.
group :development do
  gem 'capistrano' #, '~>2.11.2'
  gem 'capistrano_colors'
  gem 'net-ssh', '2.4.0'
end 

# Debug Tools
group :development do

  # debugger: http://guides.rubyonrails.org/debugging_rails_applications.html
  #gem 'debugger'                   

  gem 'better_errors'              # see Railscasts #402               
  gem 'binding_of_caller'
  gem 'meta_request'
end

# RSpec, see: http://ruby.railstutorial.org/chapters/static-pages#sec:first_tests
group :test, :development do
  gem 'guard', '1.0.1'
  gem 'guard-focus'
  gem 'rspec-rails', '2.10.0'
  gem 'guard-rspec', '0.5.5'
#  gem 'rspec-mocks'
#  gem 'listen'
#  gem 'rb-inotify', '0.8.8' if RUBY_PLATFORM.downcase.include?("linux")
end
group :test do
  gem 'capybara' ,'>=2.0.2'
  gem 'launchy'
  gem 'factory_girl_rails', '>= 4.0.0' # '1.4.0'
  gem 'database_cleaner'
  gem 'guard-spork'
  gem 'spork'
  gem 'simplecov', require: false
end

# This is for testing on wingolfsplattform.org -- since travis-pro has expired.
group :test do
  # simulating enter via "\n" does not work after 1.1.2
  # https://github.com/jonleighton/poltergeist/issues/388
  gem 'poltergeist', '1.1.2'  # 1.1.2: \n works, 1.2.0 works not, 1.4.1
end

# Automatische Anzeige des Red-Green-Refactor-Zyklus.
# Packages: see: http://ruby.railstutorial.org/chapters/static-pages
# Diese Pakete scheinen nicht mehr notwendig zu sein und vielmehr Guard zum Absturz zu bringen (SF 2012-06-06)
#group :test do
#  if RUBY_PLATFORM.downcase.include?("linux")
#    gem 'rb-inotify' #, '0.8.8'
#    gem 'libnotify' #, '0.5.9'
#  end
#  if RUBY_PLATFORM.downcase.include?("darwin") # Mac
#    gem 'rb-fsevent', :require => false
#    gem 'growl'      
#  end
#  if RUBY_PLATFORM.downcase.include?("windows")
#   gem 'rb-fchange'
#    gem 'rb-notifu'
#    gem 'win32console'
#  end
#end


# password generator. it's not pwgen, but it's a gem.
# TODO: if we ever find a way to properly include pwgen, let's do it.
gem 'passgen'                                                           # MIT License

# YourPlatform
gem 'your_platform', path: 'vendor/engines/your_platform'

# Pry Console Addon
gem 'pry', group: :development

# Turbolinks
gem 'turbolinks', '>= 1.0'

# Angular JS
gem 'angularjs-rails'

# Receiving Mails
gem 'mailman', require: false
gem 'mail', git: 'git://github.com/jeremy/mail.git'
gem 'rb-inotify', '~> 0.9', group: :production

# Encoding Detection
gem 'charlock_holmes'

# Manage Workers
gem 'foreman', group: [:development, :production]

# CMS: Mercury Editor
gem 'mercury-rails', git: 'git://github.com/jejacks0n/mercury'

# readline (for rails console)
# see https://github.com/luislavena/rb-readline/issues/84#issuecomment-17335885
#gem 'rb-readline', '~> 0.5.0', group: :development, require: 'readline' 

gem 'gmaps4rails', git: 'git@github.com:fiedl/Google-Maps-for-Rails.git'

