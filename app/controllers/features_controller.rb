require_dependency YourPlatform::Engine.root.join('app/controllers/features_controller').to_s

module FeaturesControllerOverride

  private

  def discourse_features_url
    "https://discourse.wingolfsplattform.org/c/plattform-features"
  end

  def github_issues_url
    "https://github.com/fiedl/wingolfsplattform/issues"
  end

end

class FeaturesController
  prepend FeaturesControllerOverride
end

