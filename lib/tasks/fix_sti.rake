# Fixing single-table-inheritance (STI) issues.
#
namespace :fix do

  task :sti => [
    'sti:corporations',
    'sti:bvs',
    'sti:aktivitates',
    'sti:philisterschaften',
  ]
  
  namespace :sti do
    
    task :requirements do
      require 'importers/models/log'
    end
        
    task :print_info => [:requirements] do
      log.head "Fix STI Issues"
      log.info "Dieser Task führt Korrekturen für Single-Table-Inheritance durch."
      log.info ""
    end
    
    task :corporations => [:environment, :requirements, :print_info] do
      log.section "Corporations"
      Corporation.corporations_parent.child_groups.where(type: '').each do |group|
        unless group.has_flag? :officers_parent
          log.info group.name
          group.update_attribute :type, 'Corporation'
        end
      end
      log.success 'Fertig.'
    end

    task :bvs => [:environment, :requirements, :print_info] do
      log.section "BVs"
      Bv.bvs_parent.child_groups.where(type: '').each do |group|
        unless group.has_flag? :officers_parent
          log.info group.name
          group.update_attribute :type, 'Bv'
        end
      end
      log.success 'Fertig.'
    end

    task :aktivitates => [:environment, :requirements, :print_info] do
      log.section "Aktivitates"
      Group.alle_aktiven.child_groups.where(type: '').each do |group|
        unless group.has_flag? :officers_parent
          log.info group.name
          group.update_attribute :type, 'Aktivitas'
        end
      end
      log.success 'Fertig.'
    end

    task :philisterschaften => [:environment, :requirements, :print_info] do
      log.section "Philisterschaften"
      Group.alle_philister.child_groups.where(type: '').each do |group|
        unless group.has_flag? :officers_parent
          log.info group.name
          group.update_attribute :type, 'Philisterschaft'
        end
      end
      log.success 'Fertig.'
    end
    
  end
  
  def log
    $log ||= Log.new
  end
  
end

