class ApplicationController < ActionController::Base

  layout "bootstrap"

  # TODO: Change before_filter to before_action  (http://stackoverflow.com/questions/16519828)
  #
  before_filter :redirect_www_subdomain, :set_locale
  helper_method :current_user
  helper_method :current_navable, :current_navable=, :point_navigation_to
  
  # This method returns the currently signed in user.
  #
  def current_user
    current_user_account.user if current_user_account
  end
  
  # This method returns the navable object the navigational elements on the 
  # currently shown page point to.
  #
  # For example, if the bread crumb navigation reads 'Start > Intranet > News', 
  # the current_navable would return the with 'News' associated navable object.
  # 
  # This also means, that the current_navable has to be set in the controller
  # through point_navigation_to.
  # 
  def current_navable
    @navable
  end
  
  # This method sets the currently shown navable object. 
  # Have a look at #current_navable.
  #
  def current_navable=( navable )
    @navable = navable
  end
  def point_navigation_to( navable )
    self.current_navable = navable
  end
  
  # Redirect the www subdomain to non-www, e.g.
  # http://www.example.com to http://example.com.
  #
  def redirect_www_subdomain
    if (request.host.split('.')[0] == 'www') and (not Rails.env.test?)
      # A flash cross-domain flash message would only work if the cookies are shared between the subdomains.
      # But we won't make this decision for the main app, since this can be a security risk on shared domains.
      # More info on sharing the cookie: http://stackoverflow.com/questions/12359522/
      #
      flash[:notice] = I18n.t(:you_may_leave_out_www)
      redirect_to "http://" + request.host.gsub('www.','')
    end
  end
  
  # The locale of the application s set as follows:
  #   1. Use the url parameter 'locale' if given.
  #   2. Use the language of the web browser if supported by the app.
  #   3. Use the default locale if no other could be determined.
  #
  def set_locale
    cookies[:locale] = params[:locale] if params[:locale].present?
    cookies[:locale] = nil if params[:locale] and params[:locale] == ""
    cookies[:locale] = nil if cookies[:locale] == ""
    I18n.locale = cookies[:locale] || browser_language_if_supported_by_app || I18n.default_locale
  end
  
  private
  def extract_locale_from_accept_language_header
    # see: http://guides.rubyonrails.org/i18n.html
    if request.env['HTTP_ACCEPT_LANGUAGE'] and not Rails.env.test?
      request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first.to_sym
    end
  end
  def browser_language_if_supported_by_app
    ([extract_locale_from_accept_language_header] & I18n.available_locales).first
  end

end