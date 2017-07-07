#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

# This is needed for `rake db:migrate` et cetera:
#
Wingolfsplattform::Application.load_tasks

# This is a hack to fix "Don't know how to build task 'test:prepare'":
# https://github.com/rspec/rspec-rails/issues/936#issuecomment-36129887
#
task 'test:prepare' do
  # This task does not do anything.
end

task :tests do
  sh "rspec spec/models spec/features"
end

task test: :tests
task default: :tests

# https://github.com/github/gemoji
# run `rake emoji` to copy emoji files to `public/emoji`
load 'tasks/emoji.rake'
