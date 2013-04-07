
class UserGroupMembershipsController < ApplicationController

  before_filter :find_membership
#  respond_to :html, :json
  respond_to :json

  def show
    # update  # 2013-02-03 SF: This seems wrong, does it not?
  end

  def update
    attributes = params[ :user_group_membership ]
    attributes ||= params[ :status_group_membership ]

    @membership.update_attributes( attributes )
#    if @membership.update_attributes( attributes )
#      respond_to do |format|
#        format.json do
#          #head :ok
#          respond_with_bip @membership
#        end
#      end
      respond_with @membership
#    else
#      raise "updating attributes of user_group_membership has failed: " + @membership.errors.full_messages.first
#    end
  end

  def destroy
    if @membership
      @membership.destroy
      redirect_to :back
    end
  end

  private

  def find_membership
    p "controller", params
    p "------------------------------------------------------------------------------------------"
    if params[ :id ].present?
      @membership = UserGroupMembership.with_deleted.find( params[ :id ] )
    else
      user = User.find params[ :user_id ] if params[ :user_id ]
      group = Group.find params[ :group_id ] if params[ :group_id ]
      if user && group
        @membership = UserGroupMembership.with_deleted.find_by_user_and_group user, group
      end
    end
  end
  
end
