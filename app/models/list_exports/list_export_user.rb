require_dependency YourPlatform::Engine.root.join('app/models/list_exports/list_export_user').to_s

module ListExports
  class ListExportUser
    
    def cached_bv_name
      bv.try(:name)
    end

    def cached_bv_token
      bv.try(:token)
    end
    
  end
end