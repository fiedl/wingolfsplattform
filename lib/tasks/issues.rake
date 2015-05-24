namespace :issues do
  require 'importers/models/log'
  
  # This task is run by a cron job every night
  # through the nightly:all rake task.
  #
  task :all => [
    :print_info,
    :auto_fix_postal_addresses,
    :scan_for_issues
  ]
  
  task :print_info => [:environment] do
    log.section "Versuche, aktuelle Verwaltungsprobleme festzustellen und zu beheben."
    log.info "Probleme, die nicht behoben werden konnten, werden Administratoren als "
    log.info "'Verwaltungsaufgaben' angezeigt."
  end
  task :auto_fix_postal_addresses => [:environment] do
    ProfileFieldTypes::Address.fix_one_liner_addresses
  end
  task :scan_for_issues => [:environment] do
    Issue.scan
  end
end