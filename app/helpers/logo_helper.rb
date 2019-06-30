require_dependency YourPlatform::Engine.root.join('app/helpers/logo_helper').to_s

module LogoHelper

  def global_logo_url
    image_url("icon-256x256.png")
  end

end
