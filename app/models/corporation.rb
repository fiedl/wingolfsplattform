# This extends the your_platform Corporation model.
require_dependency YourPlatform::Engine.root.join( 'app/models/corporation' ).to_s

# Wingolf-am-Hochschulort-Gruppe
class Corporation

  def aktivitas
    child_groups.where(type: 'Aktivitas').first
  end

  def philisterschaft
    child_groups.where(type: 'Philisterschaft').first
  end

  def burschia
    sub_group("Burschen")
  end

  def hausverein
    child_groups.where(type: "Groups::Wohnheimsverein").first
  end

  def wohnheimsverein
    hausverein
  end

  def verstorbene
    self.child_groups.where(name: "Verstorbene").first
  end

  def chargierte
    chargen.try(:members) || []
  end

  def chargen
    descendant_groups.where(name: ["Chargierte", "Chargen"]).first
  end

  def email
    chargen_mailing_list.try(:value) || super
  end

  def self.find_all_wingolf_corporations
    self.all.select do |corporation|
      not corporation.token.include? "!"  # Falkensteiner!
    end
  end

  def self.active
    self.aktive_verbindungen
  end

  def self.aktive_verbindungen
    Corporation.joins(:child_groups).where(child_groups_groups: {id: Aktivitas.active})
  end

  # Verstorbene und Ausgetretene dürfen nicht als Mitglieder
  # der Verbindungen gezählt werden, damit sie
  #
  #   (a) nicht in der Mitgliederliste auftauchen,
  #   (b) keine Sammelnachrichten erhalten,
  #   (c) nicht in Export-Listen und Etiketten enthalten sind.
  #
  def memberships(reload = nil)
    if aktivitas && philisterschaft
      aktivitas_and_philisterschaft_member_ids = aktivitas.member_ids + philisterschaft.member_ids
      super(reload).where(descendant_id: aktivitas_and_philisterschaft_member_ids)
    else
      super(reload)
    end
  end
  def members(reload = nil)
    descendant_users(reload).includes(:links_as_descendant).where(dag_links: {id: memberships.pluck(:id)})
  end

end
