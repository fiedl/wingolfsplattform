require_dependency YourPlatform::Engine.root.join('app/controllers/users_controller').to_s

module UsersControllerModifications

  private

  def user_params
    additional_permitted_keys = []
    additional_permitted_keys += [:wingolfsblaetter_abo, :localized_bv_beitrittsdatum] if @user && can?(:update, @user)
    params.require(:user).permit(*(super.keys + additional_permitted_keys))
  end

end

class UsersController
  prepend UsersControllerModifications
end
