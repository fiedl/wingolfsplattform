require_dependency YourPlatform::Engine.root.join('app/models/issue').to_s

module IssueOverride
  module ClassMethods
    def scan_address_field(address_field)
      address_field.issues.destroy_all

      # Auf fehlerhafte Adressen sollen überprüft werden:
      # - Alle Gruppen
      # - Alle Personen: Nur dann, wenn sie Wingolfiten und nicht verstorben sind.
      # - Nur Post- bzw. Primäranschriften.
      #
      if address_field.profileable.kind_of?(Group) or (
        address_field.profileable.kind_of?(User) and
        address_field.profileable.alive? and
        address_field.profileable.wingolfit? and
        address_field.postal_or_first_address?
        )
        super
      end
    end

    def with_wbl_abo
      ids = self.all.select do |issue|
        profileable = issue.reference.try(:profileable)
        profileable.kind_of?(User) and profileable.wingolfsblaetter_abo
      end
      self.where(id: ids)
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

  scope :wingolfsblaetter, -> { concerning_postal_addresses.unresolved.with_wbl_abo }
end
