# -*- coding: utf-8 -*-

                                                                                           # Licenses
                                                                                           # =======================================

source 'https://rubygems.org'						                                                   # Ruby License,
                                                                                           # http://www.ruby-lang.org/en/LICENSE.txt



gem 'rails', '~> 4.1.1'						# MIT License,
    	     								# http://www.opensource.org/licenses/mit-license.php

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'mysql2'								# MIT License

gem 'sass-rails',   '>= 3.2.3'					# MIT License
gem 'coffee-rails', '>= 3.2.1'					# MIT License
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

# Debug Tools
group :development do

  # debugger: http://guides.rubyonrails.org/debugging_rails_applications.html
  #gem 'debugger'

  #gem 'better_errors'              # see Railscasts #402
  gem 'binding_of_caller'
  gem 'meta_request'
end

# Security Tools
group :development, :test do
  gem 'brakeman', '>= 2.3.1'
  gem 'guard-brakeman', '>= 0.8.1'
end

# Documentation Tools
group :development, :test do
  gem 'yard'
  #gem 'redcarpet'
end

# RSpec, see: http://ruby.railstutorial.org/chapters/static-pages#sec:first_tests
group :test, :development do
  #gem 'guard', '>= 2.2.5'
  gem 'guard-focus'
  #gem 'rspec-rails'
  #gem 'guard-rspec'
#  gem 'rspec-mocks'
#  gem 'listen'
#  gem 'rb-inotify', '0.8.8' if RUBY_PLATFORM.downcase.include?("linux")
  gem 'spring' # already in Rails 4.1
  gem 'spring-commands-rspec'
end

group :test do
  #gem 'capybara'
  gem 'launchy'
  #gem 'factory_girl_rails', '>= 4.0.0' # '1.4.0'
  #gem 'database_cleaner'
  #gem 'guard-spork'
  gem 'spork'
  gem 'simplecov', '~> 0.7.1', require: false  # fixed to to return code issue.
  gem 'fuubar'
end

group :test do
  gem 'poltergeist', '1.5.0'
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
#gem 'pry', group: :development

# Turbolinks
gem 'turbolinks', '>= 1.0'

# Angular JS
#gem 'angularjs-rails'

# Receiving Mails
gem 'mailman', require: false
gem 'mail', git: 'git://github.com/jeremy/mail.git'
gem 'rb-inotify', '~> 0.9', group: :production

# View Helpers
# gem 'rails-gallery', git: 'https://github.com/kristianmandrup/rails-gallery'

# Encoding Detection
gem 'charlock_holmes'

# Manage Workers
#gem 'foreman', group: [:development, :production]

# CMS: Mercury Editor
gem 'mercury-rails', git: 'git://github.com/jejacks0n/mercury'

# readline (for rails console)
# see https://github.com/luislavena/rb-readline/issues/84#issuecomment-17335885
#gem 'rb-readline', '~> 0.5.0', group: :development, require: 'readline'

gem 'gmaps4rails', '~> 2.0.1', git: 'git://github.com/fiedl/Google-Maps-for-Rails.git'

# To customly set timeout time we need rack-timeout
gem 'rack-timeout'

# Metrics
gem 'fnordmetric'

# Code Coverage Badge, coveralls.io
gem 'coveralls', require: false

# Temporary Dependency Resolving
# TODO Remove when obsolete
gem 'tilt', '~> 1.4.1'

# Maintenance Mode
gem 'turnout'

# Transition to Rails 4. TODO: Remove those when obsolete.
# http://railscasts.com/episodes/415-upgrading-to-rails-4?view=asciicast
#
gem 'best_in_place', git: 'git://github.com/bernat/best_in_place.git'
gem 'protected_attributes'
gem 'activerecord-deprecated_finders'


# for time travels during tests
gem 'timecop'

gem 'temporal_scopes', git: 'git://github.com/fiedl/temporal_scopes.git'
#gem 'temporal_scopes', path: '../temporal_scopes'

gem 'cancancan', '~> 1.8'

# fix version for rails 4 transition (minimal update)
# TODO: remove these when http://stackoverflow.com/questions/24877058 is resolved.
#
gem 'acts_as_tree', '1.6.0'
gem 'angularjs-rails', '1.2.13'
#gem 'best_in_place', '2.1.0'
gem 'better_errors', '0.7.0'
gem 'capybara', '2.2.0'
gem 'database_cleaner', '0.9.1'
gem 'factory_girl', '4.3.0'
gem 'factory_girl_rails', '4.3.0'
gem 'foreman', '0.63.0'
gem 'geocoder', '1.2.1'
gem 'guard', '2.2.5'
gem 'guard-rspec', '0.5.5'
gem 'guard-spork', '1.0.1'
gem 'phony', '2.2.8'
gem 'pry', '0.9.12.4'
gem 'rack-mini-profiler', '0.9.1'
gem 'redcarpet', '3.0.0'
gem 'rspec-core', '2.14.7'
gem 'rspec-expectations', '2.14.4'
gem 'rspec-mocks', '2.14.4'
gem 'rspec-rails', '2.14.1'
gem 'will_paginate', '3.0.5'
