require_dependency YourPlatform::Engine.root.join('app/models/corporation_score').to_s

class CorporationScore

  def scope
    corporation.aktivitas
  end

end