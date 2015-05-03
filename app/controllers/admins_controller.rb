class AdminsController < ApplicationController
  
  before_action :find_resources
  
  def index
    authorize! :index, :admins
  end
  
  def find_resources
    @global_admins_parent_group = Group.everyone.admins_parent
    @corporations = Corporation.all
    @bvs = Bv.all
    
    # responsible are: local admins + last global admin:
    @admins_responsible_for_me = (current_user.admins_of_self_and_ancestors - Group.global_admins.members[0..-2]).uniq
  end
  
end