class Philisterschaft < Group

  def erstbandphilister
    erstbandphilister_parent.members
  end

  def erstbandphilister_parent
    find_or_create_erstbandphilister_parent
  end

  def find_or_create_erstbandphilister_parent
    # `first_or_create` does not work for Rails 5, but did work for 4.2. TODO: Check again, when migrating to Rails 5.1.
    child_groups.where(name: "Erstbandphilister", type: "Groups::Erstbandtraeger").first || child_groups.create(name: "Erstbandphilister", type: "Groups::Erstbandtraeger").becomes(Groups::Erstbandtraeger)
  end

end
