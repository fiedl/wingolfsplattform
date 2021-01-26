#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'fiedl/log'

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

export_path = File.join Rails.root, "exports"
task :export => [
  :export_info,
  :export_aktivitates,
  :encrypt_export_folders
]

task :export_info do
  log.head "Export der Mitgliederdaten"
  log.info "Ziel: #{export_path}"
end

task :export_aktivitates => :environment do
  log.section "Exportiere Mitgliederdaten der Aktivitates"
  Aktivitas.active.all.each do |aktivitas|
    domain = aktivitas.corporation.subdomain || raise('no domain present')
    aktivitas_export_folder = File.join export_path, domain

    print "#{domain.blue} ..."
    FileUtils.mkdir_p aktivitas_export_folder
    aktivitas.members.each do |member|
      member.backup_profile
      FileUtils.cp member.latest_backup_file, aktivitas_export_folder
    end
    log.success "ok"
  end
end

task :encrypt_export_folders do
  log.section "Verschlüsselung der Export-Ordner"
  log.info "Basisverzeichnis: #{export_path}"

  passwords = {}
  directories = Dir.glob(File.join(export_path, "*")).select { |f| File.directory?(f) }
  directories.each do |directory|
    domain = File.basename directory
    encryption_password = `pwgen 48`.strip
    passwords[domain] = encryption_password
    destination_zip_file = "#{domain}.zip"
    print "#{destination_zip_file.blue} ..."
    `cd #{export_path} && zip --encrypt --recurse-paths --password=#{encryption_password} #{destination_zip_file} #{domain}`
    log.info encryption_password
    log.success " ok"
  end

  log.section "Passwörter"
  passwords_file = File.join(export_path, "encryption_passwords.json")
  log.info "Passwort-Sammlung zur Entschlüsselung: #{passwords_file}"
  File.write passwords_file, passwords.to_json
end