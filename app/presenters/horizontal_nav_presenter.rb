require_dependency YourPlatform::Engine.root.join('app/presenters/horizontal_nav_presenter').to_s

module HorizontalNavPresenterOverride
  
  # Bezirksverbände immer abgekürzt aufführen, z.B. "BV 37"
  # anstelle von "BV 37 - Mittelfranken".
  #
  def possibly_shortened_title_for(object)
    if object.kind_of? Bv
      object.token
    else
      super(object)
    end
  end
  
end

class HorizontalNavPresenter
  prepend HorizontalNavPresenterOverride
end