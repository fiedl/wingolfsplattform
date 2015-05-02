namespace :fix do
  task :dag_links => [                                                                                                  
    'dag_links:all'
  ]
  
  namespace :dag_links do
    task :requirements => [:environment] do
      require 'importers/models/log'
    end
    task :print_info => [:requirements] do
      log.head "Fix DagLink objects"
    end
    
    task :all => [:environment, :print_info] do
      DagLink.repair
    end
  end
end
