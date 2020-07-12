class Api::V1::Users::Leibfamilie::LeibfuxenController < Api::V1::BaseController

  expose :user

  api :POST, '/api/v1/users/ID/leibfamilie/leibfuxen'
  param :leibfux_id, :number, "Set the leibfux of the user"

  def create
    authorize! :update, user

    if params[:leibfux_id]
      User.find(params[:leibfux_id]).leibbursch = user
    end

    render json: {}, status: :ok
  end

end