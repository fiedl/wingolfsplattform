namespace :fix do
  task :memberships => [
    'memberships:all'
  ]

  namespace :memberships do
    task :print_info => [:environment] do
      log.head "Fix user group memberships"
    end

    task :all => [:environment, :print_info] do
      log.section "Fixing indirect membership validity ranges"
      DagLink.recalculate_indirect_validity_ranges
      log.success "\nFertig."
    end

  end
end
