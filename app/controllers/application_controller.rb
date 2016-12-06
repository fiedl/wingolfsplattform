# This extends the your_platform ApplicationController
require_dependency YourPlatform::Engine.root.join('app/controllers/application_controller').to_s

module ApplicationControllerOverrides

end

class ApplicationController
  prepend ApplicationControllerOverrides

  before_action :new_relic_params
  before_action :collect_data_for_exception_notifier

  protected

  def permitted_layouts
    super + %w(wingolf)
  end

  def default_layout
    if Rails.env.test?
      'bootstrap'
    else
      'wingolf'
    end
  end

  def new_relic_params
    ::NewRelic::Agent.add_custom_parameters({
      path: request.path,
      user_id: (current_user ? current_user.id : nil),
      role_view: current_role_view
    })
  end

  def collect_data_for_exception_notifier
    request.env["exception_notifier.exception_data"] = {
      :current_user => current_user
    }
  end

end