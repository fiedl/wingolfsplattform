require_dependency YourPlatform::Engine.root.join('app/controllers/groups_controller').to_s

module GroupsControllerOverride
  
  # For STI reasons, we have to override this method in order
  # to get the BV params into the group params variable.
  #
  def group_params
    params[:group] ||= params[:bv]  # for Bv objects
    params[:group] ||= params[:aktivitas]
    params[:group] ||= params[:philisterschaft]
    super
  end
  
end

class GroupsController
  prepend GroupsControllerOverride
end