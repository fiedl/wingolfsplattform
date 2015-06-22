namespace :notifications do
  
  task :worker => [:environment] do
    detect_environment
    if production_stage_or_development_environment?
      Rake::Task["your_platform:notifications:worker"].invoke
    else
      sleep 1.hour # to reduce start-stop load if managed by a monitoring tool.
    end
  end
  
  task :process => [:environment] do
    detect_environment
    Rake::Task["your_platform:notifications:process"].invoke
  end
  
  def production_stage_or_development_environment?
    if @production_stage_or_development_environment
      return true
    else
      print "   [Skipped due to staging environment.]\n"
      return false
    end
  end
  
  def detect_environment
    print "   Environment: #{Rails.env.to_s}, Stage: #{::STAGE}\n"
    @production_stage_or_development_environment = true if Rails.env.development? or ::STAGE == "wingolfsplattform" # wingolfsplattform-master, wingolfsplattform-sandbox
  end
end