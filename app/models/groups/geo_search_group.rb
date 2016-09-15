require_dependency YourPlatform::Engine.root.join('app/models/groups/geo_search_group').to_s

module Groups
  module GeoSearchGroupOverrides

    def apply_status_selector(users)
      super.select do |user|
        user.wingolfit?
      end
    end

  end

  class GeoSearchGroup
    prepend GeoSearchGroupOverrides
  end
end