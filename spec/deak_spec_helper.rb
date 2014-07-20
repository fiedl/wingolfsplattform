#
# This file contains the configuration of our test suite.
# We are using the following tools:
# 
# RSpec             Defining test-driven or behavior-driven specifications of 
#                   software components. 
#                   http://rspec.info/
#
# rspec-rails       Integration of RSpec into Rails, providing generators, et cetera.
#                   https://github.com/rspec/rspec-rails
#
# Guard             Detecting changed files and running corresponding tests in the
#                   background during development.
#                   https://github.com/guard/guard
#
# Spring            Keeping some less frequently changing components in memory
#                   in order to increase test performance, i.e. minimize the time
#                   Guard needs to restart the tests.
#                   This preloader is part of Rails 4.1. It replaces Spork and Zeus.
#                   https://github.com/rails/spring
#
# Capybara          Simulating user interaction in order to write high level
#                   integration tests. 
#                   https://github.com/jnicklas/capybara
#
# PhantomJS         Simulated browser for running integration tests headless,
#                   including the execution of JavaScript and AJAX requests. 
#                   http://phantomjs.org/
# 
# poltergeist       Driver to use PhantomJS with Capybara.
#                   https://github.com/jonleighton/poltergeist
#
# FactoryGirls      Library to provide test data objects. 
#                   https://github.com/thoughtbot/factory_girl
# 
# SimpleCov         Tool to detect the test coverage of our code.
#                   https://github.com/colszowka/simplecov
# 
# Coveralls         Tool to add a code coverage badge.
#                   https://coveralls.io/docs/ruby
#


# Required Basic Libraries
# ==========================================================================================

require 'rubygems'

# To create an online coverage report on coveralls.io, 
# init their gem here.
#
require 'coveralls'
Coveralls.wear! 'rails'


# Prefork (this is run only once)
# ==========================================================================================

# These requirements and configurations are loaded by Spork or Zeus.
# They will be cached in memory.
#
# Remember to restart Spork/Zeus whenever you need to reload one
# of the components. If you find yourself to often restarting guard because of this,
# you should probably move the concerning component into the `each_run` block.
#
prefork = lambda {
  
  # This block is read from spec/spec_prefork.rb.
  # It is necessary to put this in another file since spring hasn't got a
  # prefork callback.
  #
  # https://github.com/rails/spring#running-code-before-forking
  #
  require File.expand_path('../../spec/spec_prefork', __FILE__)

}


# This is run on each run of the test suite.
# ==========================================================================================

# These requirements and configurations are loaded on each run of the test suite
# without being cached by Spork/Zeus.
#
each_run = lambda {

  # There are some actions FactoryGirl needs to perform on every run.
  #
  FactoryGirl.reload
  Dir[Rails.root.join('spec/support/**/*.rb')].each {|f| require f}

  # Resource on using SimpleCov together with Spork:
  # https://github.com/colszowka/simplecov/issues/42#issuecomment-4440284
  #
  if ENV['DRB']
    require 'simplecov'
  end
  
}


# Zeus, Spork, Spring, Nothing.
# ==========================================================================================

# The following code passes the defined blocks `prefork` and `each_run` to the
# tool that is used, i.e. either spring, spork or zeus. If none is used, they are simply
# called causing the file to behave like a regular spec_helper.
#
# More information:
# https://github.com/burke/zeus/wiki/Spork
#
if defined?(Zeus)
  prefork.call
  $each_run = each_run
  class << Zeus.plan
    def after_fork_with_test
      after_fork_without_test
      $each_run.call
    end
    alias_method_chain :after_fork, :test
  end
elsif ENV['spork'] || $0 =~ /\bspork$/
  require 'spork'
  Spork.prefork(&prefork)
  Spork.each_run(&each_run)
elsif defined?(SPEC_PREFORK_HAS_RUN)
  # The prefork is already called by the spring startup.
  # https://github.com/rails/spring#running-code-before-forking
  each_run.call
else
  prefork.call
  each_run.call
end