class Groups::Wohnheimsverein < Group

  def occupants_parent
    corporation.descendant_groups.where(type: "Groups::Room").limit(1).first.try(:parent)
  end

  def rooms
    corporation.descendant_groups.where(type: "Groups::Room")
  end

  def kassenwarte
    officers_groups.flagged(:kassenwart).first.try(:members) || []
  end

end