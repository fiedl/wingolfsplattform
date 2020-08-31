class Groups::WohnheimsvereineController < ApplicationController

  expose :group, -> { Group.find params[:id] }

  def show
    authorize! :read, group

    set_current_navable group
    set_current_title group.title
  end

  def update
    authorize! :update, group

    group.update! group_params
    render json: {}, status: :ok
  end

  private

  def group_params
    params.require(:groups_wohnheimsverein).permit(:name, :body, :avatar, :avatar_background)
  end

end