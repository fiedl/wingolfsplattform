#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rspec/core/rake_task'
require 'rspec-rerun'

# This is needed for `rake db:migrate` et cetera:
#
Wingolfsplattform::Application.load_tasks

# This is a hack to fix "Don't know how to build task 'test:prepare'":
# https://github.com/rspec/rspec-rails/issues/936#issuecomment-36129887
#
task 'test:prepare' do
  p "test:prepare: THIS TASK DOESN'T DO ANYTHING ANYMORE."
end

pattern = "{./spec/**/*_spec.rb,./vendor/engines/**/spec/**/*_spec.rb}"

ENV['RSPEC_RERUN_RETRY_COUNT'] ||= '3'
ENV['RSPEC_RERUN_PATTERN'] ||= pattern

task default: 'rspec-rerun:spec'

# task :default => :spec
# 
# Rake::Task[ :spec ].clear
# RSpec::Core::RakeTask.new( :spec ) do |t|
#   t.pattern = pattern
# end

# https://github.com/github/gemoji
# run `rake emoji` to copy emoji files to `public/emoji`
load 'tasks/emoji.rake'
