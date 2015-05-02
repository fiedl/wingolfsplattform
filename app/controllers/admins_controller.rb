class AdminsController < ApplicationController
  
  before_action :find_resources
  
  def index
    authorize! :index, :admins
  end
  
  def find_resources
    @global_admins_parent_group = Group.everyone.admins_parent
    @corporations = Corporation.all
    @bvs = Bv.all
  end
  
end