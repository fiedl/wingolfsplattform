namespace :nightly do
  require 'importers/models/log'

  # This task is run by a cron job every night.
  #
  task :all => [:environment] do
    log.head "Nächtliche Aufgaben: #{I18n.localize(Time.zone.now)}"

    # if Time.zone.now.monday?
    #   log.info "Montag: BV-Mitgliedschaften reparieren"
    #   Rake::Task["fix:bvs"].invoke
    # end
    #
    # if Time.zone.now.tuesday?
    #   log.info "Dienstag: Gruppen-Mitgliedschaften reparieren"
    #   Rake::Task["fix:memberships:later"].invoke
    # end

    if Time.zone.now.wednesday?
      log.info "Mittwoch: Auf Verwaltungsprobleme scannen"
      Rake::Task["issues:all"].invoke
    end

    # if Time.zone.now.thursday?
    #   log.info "Donnerstag: Wingolfiten-Caches erneuern (Sidekiq)"
    #   Rake::Task["cache:renew_later:wingolfiten"].invoke
    # end
    #
    # if Time.zone.now.friday?
    #   log.info "Freitag: Gruppen-Caches erneuern (Sidekiq)"
    #   Rake::Task["cache:renew_later:groups"].invoke
    # end

    log.head "Nächtliche Aufgaben"
    log.success "Abgeschlossen: #{I18n.localize(Time.zone.now)}"
  end

end