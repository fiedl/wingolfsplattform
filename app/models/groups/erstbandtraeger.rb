# Wenn eine Gruppe dieses Typs als Untergruppe einer Corporation
# oder einer Philisterschaft oder Aktivitas eingehängt wird,
# enthält sie alle Mitglieder der Elterngruppe, die dieser
# Verbindung zuerst beigetreten sind.
#
class Groups::Erstbandtraeger < Group

  def members
    User.where(id: member_ids)
  end

  def member_ids
    parent.members.select do |member|
      member.first_corporation.id == parent_corporation.id
    end.map(&:id)
  end

  def parent_corporation
    @parent_corporation ||= parent.corporation
  end

  # This is used to determine the routes for this resource.
  # http://stackoverflow.com/a/9463495/2066546
  def self.model_name
    Group.model_name
  end

  if use_caching?
    cache :member_ids
  end

end