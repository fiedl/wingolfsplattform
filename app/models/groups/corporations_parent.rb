require_dependency YourPlatform::Engine.root.join('app/models/groups/corporations_parent').to_s

class Groups::CorporationsParent

  def important_officer_keys
    [:senior, :fuxmajor, :kneipwart, :phil_x]
  end

end