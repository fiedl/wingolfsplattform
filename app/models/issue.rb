require_dependency YourPlatform::Engine.root.join('app/models/issue').to_s

module IssueOverride
  module ClassMethods
    def scan_address_field(address_field)
      address_field.issues.destroy_all
      
      # Auf fehlerhafte Adressen sollen überprüft werden:
      # - Alle Gruppen
      # - Alle Personen: Nur dann, wenn sie Wingolfiten und nicht verstorben sind.
      #
      if address_field.profileable.kind_of?(Group) or (address_field.profileable.kind_of?(User) and address_field.profileable.alive? and address_field.profileable.wingolfit?)
        super
      end
    end
  end
  
  def self.prepended(base)
    class << base
      prepend ClassMethods
    end
  end
end

class Issue
  prepend IssueOverride
end
