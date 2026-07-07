#!/usr/bin/env ruby

# Prepares the environment for development scripts like bin/rspec.
# This script runs inside the tests container (see bin/docker_wrapper);
# it is skipped if it already ran within the last 24 hours.

require 'fiedl/log'

def shell(command)
  log.prompt command
  system(command) or abort "Command failed: #{command}"
end

log.section "Preparing Environment"

log.info "RAILS_ENV: #{ENV['RAILS_ENV'] || 'development'}"
log.info ""

LOCK_FILE = "tmp/setup_last_run_#{ENV['RAILS_ENV']}"
if !File.exist?(LOCK_FILE) || ((Time.now - File.mtime(LOCK_FILE)) > 86400)
  shell "bundle exec rails your_platform:install:node_modules"

  if ENV['RAILS_ENV'] == 'test'
    # The test database is disposable — recreate it from the current
    # schema. Dropping first, because schema:load cannot DROP tables
    # past foreign keys.
    system "bundle exec rails db:environment:set 2>/dev/null"
    system "bundle exec rails db:drop 2>/dev/null"
    shell "bundle exec rails db:create db:schema:load"
  else
    shell "bundle exec rails db:create"
    # A fresh database gets the schema from db/schema.rb: the migration
    # history contains mysql-only SQL and is not replayed on postgres.
    if `bundle exec rails db:version 2>/dev/null`.include?("Current version: 0")
      shell "bundle exec rails db:schema:load"
    end
    shell "bundle exec rails db:migrate db:seed"
  end

  require 'fileutils'
  FileUtils.mkdir_p "tmp"
  File.write(LOCK_FILE, Time.now.to_s)
else
  log.info "Setup block already ran within the last 24 hours. Skipping."
  log.info "To force re-run, delete #{LOCK_FILE}.\n"
end
