#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rspec/core/rake_task'

Wingolfsplattform::Application.load_tasks


# The task `rake spec` is defined by the rspec-rails gem.
# We have to customize it here in order to include the your_platform engine.
# 
# For more information on how to customize the task, see:
#   * https://github.com/rspec/rspec-rails#customizing-rake-tasks
#   * https://www.relishapp.com/rspec/rspec-core/docs/command-line/rake-task
#
Rake::Task[ :spec ].clear
RSpec::Core::RakeTask.new( :spec ) do |t|
  t.pattern = "{./spec/**/*_spec.rb,./vendor/engines/**/spec/**/*_spec.rb}"
  t.fail_on_error = true
end

# Alternative:
#
# task :spec do
#   exit system("bundle exec rspec ./spec/**/*_spec.rb ./vendor/engines/**/spec/**/*_spec.rb")
# end

# The default rake task, i.e. when running just `rake`, is `rake spec`.
#
task :default => :spec