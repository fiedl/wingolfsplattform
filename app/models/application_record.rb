require_dependency YourPlatform::Engine.root.join('app/models/application_record').to_s

module ApplicationRecordClassMethodOverrides

  def storage_namespace_keys
    ["wingolfsplattform"] + super[1..]
  end

end

ApplicationRecord.singleton_class.prepend ApplicationRecordClassMethodOverrides

class ApplicationRecord
end