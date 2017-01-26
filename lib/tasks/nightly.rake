namespace :nightly do
  require 'importers/models/log'

  # This task is run by a cron job every night.
  #
  task :all => [
    :print_info,
    'fix:bvs',
    'issues:all',
    :memberships,
    :cache,
    :print_info_finish
  ]

  task :print_info => [:environment] do
    log.head "Nächtliche Aufgaben: #{I18n.localize(Time.zone.now)}"
  end
  task :print_info_finish => [:environment] do
    log.head "Nächtliche Aufgaben"
    log.success "Abgeschlossen: #{I18n.localize(Time.zone.now)}"
  end
  task :cache => ['cache:all']

  task :memberships => [:environment] do
    log.section "Mitgliedschaften"
    log.info "Jeden Donnerstag werden die indirekten Benutzergruppenmitgliedschaften gewartet, d.h. die validity ranges neu berechnet."
    if Time.zone.now.thursday?
      Rake::Task["fix:memberships"].invoke
    end
  end

end