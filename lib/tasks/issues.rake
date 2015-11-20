namespace :issues do
  require 'importers/models/log'
  
  # This task is run by a cron job every night
  # through the nightly:all rake task.
  #
  task :all => [
    :print_info,
    :scan_for_issues,
    :notify_admins
  ]
  
  task :print_info => [:environment] do
    log.section "Versuche, aktuelle Verwaltungsprobleme festzustellen und zu beheben."
    log.info "Probleme, die nicht behoben werden konnten, werden Administratoren als "
    log.info "'Verwaltungsaufgaben' angezeigt."
  end
  task :scan_for_issues => [:environment] do
    Issue.scan
  end
  task :notify_admins => [:environment, :scan_for_issues] do
    log.section "Administratoren informieren."
    log.info "Jeden Dienstag informieren wir Administratoren über ausstehende Verwaltungsprobleme."
    if Time.zone.now.tuesday?
      Issue.notify_admins
    end
  end
end