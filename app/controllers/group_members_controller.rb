require_dependency YourPlatform::Engine.root.join('app/controllers/group_members_controller').to_s

class GroupMembersController
  def new
    authorize! :create, User
    redirect_to controller: 'aktivmeldungen', action: 'new'
  end
end