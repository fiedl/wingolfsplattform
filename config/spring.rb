#
# ## What is this?
#
# Spring is a tool that preloads the rails app into memory in order
# to make commands like `rails server`, `rspec`, etc. start faster.
#
#   prefork:      load application                                  | STORED INTO MEMORY.
#                 including this config/spring.rb                   | STORED INTO MEMORY.
#   after_fork:   callback that is run before the actual command.   | RUN EACH TIME.
#   command:      the actual command is run from the stated         | RUN EACH TIME.
#                 loaded from memory, i.e. without restarting       | RUN EACH TIME.
#                 the application.                                  | RUN EACH TIME.
#
# The prefork is run only the first time spring is used.
#
# 
# ## How to use spring?
#
# Spring is already integrated into Rails 4.1. 
# Since this project does not use binstubs, you have to prefix all
# commands that you want to use with spring:
# 
#     bundle exec spring rails server
#     bundle exec spring rake
# 
# One exception: 
# 
#     bundle exec guard
#
# We have pre-configured guard to use spring when available.
# Thus, you have to run guard just as before. 
#
# To stop spring, run `spring stop` or just close the terminal.
#
#
# ## What is this file?
# 
# This file is loaded together with the application. 
# It is the prefork block if you will.
#
# More info: https://github.com/rails/spring#running-code-before-forking
#


# ## Rspec Prefork
#
# Since spring does not have a prefork callback, the prefork block of the 
# spec_helper is called here. This code is called when spring is started 
# in the test environment.
#
if ENV['RAILS_ENV'] == 'test'
  require File.expand_path('../../spec/spec_prefork', __FILE__)
end

