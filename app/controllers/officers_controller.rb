require_dependency YourPlatform::Engine.root.join('app/controllers/officers_controller').to_s

module OfficersControllerAdditions
  
  def index
    super
    @chargen = @group.descendant_groups.flagged(:chargen).first.try(:child_groups).try(:sort_by) do |charge|
      ['senior', 'fuxmajor', 'kneipwart'].index(charge.flags.first.to_s) || 10
    end || []
    @phil_x = @group.descendant_groups.flagged(:phil_x).first
  end
end

class OfficersController
  prepend OfficersControllerAdditions
end