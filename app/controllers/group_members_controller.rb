require_dependency YourPlatform::Engine.root.join('app/controllers/group_members_controller').to_s

class GroupMembersController
  def new
    authorize! :add_group_member, group
    redirect_to controller: 'aktivmeldungen', action: 'new'
  end
end