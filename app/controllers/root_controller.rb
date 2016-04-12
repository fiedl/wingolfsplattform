require_dependency YourPlatform::Engine.root.join('app/controllers/root_controller').to_s

class RootController
  
  private
  
  # TODO: DELETE THIS METHOD (which overrides the one from YourPlatform)
  # AFTER THE PUBLIC WEBSITE IS READY.
  #
  def redirect_to_sign_in_if_needed
    unless current_user or @need_setup
      #if Page.public_website_present?
      #  redirect_to public_root_path
      #else
        redirect_to sign_in_path
      #end
    end
  end
  
end