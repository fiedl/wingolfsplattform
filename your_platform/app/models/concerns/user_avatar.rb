concern :UserAvatar do

  included do
    include HasAvatar
  end

  def default_avatar_path
    # image_path: the default avatars live in the engine's asset pipeline
    # (app/assets/images/img/), not in the host app's public/images.
    if female?
      ActionController::Base.helpers.image_path("img/avatar_female_480.png")
    else
      ActionController::Base.helpers.image_path("img/avatar_male_480.png")
    end
  end

  def default_avatar_background_path
    corporations.first.try(:avatar_background_path)
  end

end