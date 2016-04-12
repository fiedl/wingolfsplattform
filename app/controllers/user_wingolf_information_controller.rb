class UserWingolfInformationController < ApplicationController
  
  def index
    @user = User.find params[:user_id] || raise('no user_id given')
    authorize! :read, @user
    
    set_current_navable @user
    set_current_title "#{@user.title}: Wingolf"
  end
  
end