# This extends the your_platform Page model.
require_dependency YourPlatform::Engine.root.join('app/models/page').to_s

module PageOverrides
  module ClassMethods
    def types
      super + [Pages::WohnenImWingolf]
    end
  end

  def self.prepended(base)
    class << base
      prepend ClassMethods
    end
  end
end

class Page
  prepend PageOverrides
end
