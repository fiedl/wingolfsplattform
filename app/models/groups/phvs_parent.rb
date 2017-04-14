class Groups::PhvsParent < Groups::GroupOfGroups

  def important_officer_keys
    [:phil_x, :schriftwart, :kassenwart]
  end

  def child_groups_table_rows
    rows = super
    rows.each do |row|
      philisterverein = Group.find row[:child_group_id]
      row[:erstbandtraeger_count] = philisterverein.erstbandphilister.count
    end
    rows
  end

  cache :child_groups_table_rows
end