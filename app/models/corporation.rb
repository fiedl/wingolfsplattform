# -*- coding: utf-8 -*-

# This extends the your_platform Corporation model.
require_dependency YourPlatform::Engine.root.join( 'app/models/corporation' ).to_s

# Wingolf-am-Hochschulort-Gruppe
class Corporation 

  def aktivitas
    self.child_groups.select { |child| child.name == "Aktivitas" or child.name == "Activitas" }.first
  end

  def philisterschaft
    self.child_groups.select { |child| child.name == "Philisterschaft" }.first
  end

  def hausverein
    self.child_groups.select{ |child| child.name == "Hausverein" or child.name == "Wohnheimsverein" }.first
  end

end
