class Groups::WohnheimsvereineController < ApplicationController

  expose :group, -> { Group.find params[:id] }

  def show
    authorize! :read, group

    set_current_navable group
    set_current_title group.title
  end


end