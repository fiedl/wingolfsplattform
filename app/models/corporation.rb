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

  def hausverein
    self.child_groups.select{ |child| child.name == "Hausverein" or child.name == "Wohnheimsverein" }.first
  end
  
  def verstorbene
    self.child_groups.where(name: "Verstorbene").first
  end
  
  def self.find_all_wingolf_corporations
    self.all.select do |corporation|
      not corporation.token.include? "!"  # Falkensteiner!
    end
  end
  
  # Verstorbene und Ausgetretene dürfen nicht als Mitglieder
  # der Verbindungen gezählt werden, damit sie 
  #
  #   (a) nicht in der Mitgliederliste auftauchen,
  #   (b) keine Sammelnachrichten erhalten,
  #   (c) nicht in Export-Listen und Etiketten enthalten sind.
  #
  def memberships(reload = nil)
    aktivitas_and_philisterschaft_member_ids = aktivitas.member_ids + philisterschaft.member_ids
    super(reload).where(descendant_id: aktivitas_and_philisterschaft_member_ids)
  end
  def members(reload = nil)
    descendant_users(reload).includes(:links_as_descendant).where(dag_links: {id: memberships.pluck(:id)})
  end
  
end
