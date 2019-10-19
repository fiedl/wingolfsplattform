class GroupMembersController
  def new
    authorize! :create, User 
    redirect_to controller: 'aktivmeldungen', action: 'new'
  end
end