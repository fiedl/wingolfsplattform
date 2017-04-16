class Philisterschaft < Group

  default_scope { philisterschaften }

  def erstbandphilister
    erstbandphilister_parent.members
  end

  def erstbandphilister_parent
    find_or_create_erstbandphilister_parent
  end

  def find_or_create_erstbandphilister_parent
    child_groups.where(name: "Erstbandphilister", type: "Groups::Erstbandtraeger").first_or_create.becomes(Groups::Erstbandtraeger)
  end

end

class Group
  scope :philisterschaften, -> { where(name: ['Philisterschaft', 'Altherrenschaft']) }
end