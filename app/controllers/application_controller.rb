# This extends the your_platform ApplicationController
require_dependency YourPlatform::Engine.root.join('app/controllers/application_controller').to_s

module ApplicationControllerOverrides

end

class ApplicationController
  prepend ApplicationControllerOverrides

  before_action :new_relic_params
  before_action :collect_data_for_exception_notifier

  #layout             :find_layout

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

  protected

  def find_layout
    # TODO: The layout should be saved in the user's preferences, i.e. interface settings.
    layout = "wingolf" || cookies[:layout]
    layout = "bootstrap" if Rails.env.test?

    layout = "minimal" if params[:layout] == "minimal"
    layout = "wingolf" if params[:layout] == "wingolf"
    layout = "bootstrap" if params[:layout] == "bootstrap"
    layout = "compact" if params[:layout] == "compact"
    layout = "iweb" if params[:layout] == "iweb"

    cookies[:layout] = layout
    return layout
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