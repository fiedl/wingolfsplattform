require_dependency YourPlatform::Engine.root.join('app/models/app_version').to_s

class AppVersion
  def self.mobile_app_name
    "Vademecum Wingolfiticum"
  end
end
