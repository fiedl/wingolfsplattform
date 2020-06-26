class Api::V1::Users::LeibfamilieController < Api::V1::BaseController

  expose :user

  api :GET, '/api/v1/users/ID/leibfamilie', "Returns an array of {description: string, user_id: integer} objects with members of the leibfamilie of the user with the given ID."
  param :id, :number, "User id of the user requesting the leibfamilie of"

  def show
    authorize! :read, user

    render json: user.leibfamilie.as_json(methods: [:title, :avatar_url])
  end


  api :PUT, '/api/v1/users/ID/leibfamilie'
  param :leibbursch_id, :number, "Set the leibbursch of the user"

  def update
    authorize! :update, user

    if params[:leibbursch_id]
      user.leibbursch = User.find params[:leibbursch_id]
    end
  end

end