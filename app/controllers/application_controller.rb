# -*- coding: utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter      :http_authenticate

  layout             :find_layout

  helper_method      :current_user

  def current_user
    current_user_account.user if current_user_account
  end


  protected

  def http_authenticate
    return true if ENV[ 'RAILS_ENV' ] == 'test'
    authenticate_or_request_with_http_basic do |username, password|
      username == "aki" && password == "Miem8eej"
    end
  end

  def find_layout
    
    # TODO: The layout should be saved in the user's preferences, i.e. interface settings.
    layout = "wingolf"
    layout = "bootstrap" if ENV[ 'RAILS_ENV' ] == 'test'

    if params[ :layout ]
      layout = params[ :layout ] 
    end
    return layout
  end

end
