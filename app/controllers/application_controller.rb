# This extends the your_platform ApplicationController
require_dependency YourPlatform::Engine.root.join('app/controllers/application_controller').to_s

class ApplicationController

  before_action :new_relic_params
  before_action :collect_data_for_exception_notifier

  layout             :find_layout


  protected

  def find_layout
    if cookies[:layout] == 'mobile' and params[:layout].blank?
      # If it has been mobile, stay mobile, because we are
      # on a mobile app here (turbolinks-ios).
      layout = 'mobile'
    else

      # TODO: The layout should be saved in the user's preferences, i.e. interface settings.
      layout = "wingolf"
      layout = "bootstrap" if Rails.env.test?

      layout = "minimal" if layout_setting == "minimal"
      layout = "wingolf" if layout_setting == "wingolf"
      layout = "bootstrap" if layout_setting == "bootstrap"
      layout = "compact" if layout_setting == "compact"

      cookies[:layout] = layout
    end
    return layout
  end
  def layout_setting
    params[:layout] || cookies[:layout]
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