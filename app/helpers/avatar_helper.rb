require_dependency YourPlatform::Engine.root.join('app/helpers/avatar_helper').to_s

module AvatarHelperOverrides

  def user_avatar_default_url(user = nil, options = {})
    if user.try(:wingolfit?)
      "https://wingolfsplattform.org/assets/avatar_128.png"
    else
      super
    end
  end

end

module AvatarHelper
  prepend AvatarHelperOverrides
end