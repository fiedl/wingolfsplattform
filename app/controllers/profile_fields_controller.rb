require_dependency YourPlatform::Engine.root.join('app/controllers/profile_fields_controller').to_s

module ProfileFieldsControllerModifications

  private

  def profile_field_params
    params.fetch(:profile_field, {}).permit(*(super.keys + [:wingolfspost]))
  end

end

class ProfileFieldsController
  prepend ProfileFieldsControllerModifications
end
