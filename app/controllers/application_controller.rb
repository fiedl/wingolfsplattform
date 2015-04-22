
# This extends the your_platform ApplicationController
require_dependency YourPlatform::Engine.root.join( 'app/controllers/application_controller' ).to_s

class ApplicationController
  protect_from_forgery

  layout             :find_layout


  protected
  
  def find_layout
    # TODO: The layout should be saved in the user's preferences, i.e. interface settings.
    layout = "wingolf"
    layout = "bootstrap" if Rails.env.test?
    
    layout = "minimal" if layout_setting == "minimal"
    layout = "wingolf" if layout_setting == "wingolf"
    layout = "bootstrap" if layout_setting == "bootstrap"
    layout = "compact" if layout_setting == "compact"
    
    cookies[:layout] = layout
    return layout
  end
  def layout_setting
    params[:layout] || cookies[:layout]
  end
  
end
