class AdminsController < ApplicationController
  
  before_action :find_resources
  
  def index
    authorize! :index, :admins
  end
  
  def find_resources
    @global_admins_parent_group = Group.everyone.admins_parent
    @corporations = Corporation.all
    @bvs = Bv.all
    
    @admins_responsible_for_me = current_user.try(:responsible_admins)
  end
  
end