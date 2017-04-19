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
      parent_corporation && (member.first_corporation.try(:id) == parent_corporation.id)
    end.map(&:id)
  end

  def parent_corporation
    @parent_corporation ||= parent.corporation
  end

  def member_table_rows
    members.collect do |user|
      joined_at = user.date_of_joining(parent)
      joined_at = nil if joined_at && joined_at.year < 1700 # Protect from "ArgumentError: year too big to marshal: 17 UTC"
      {
        user_id: user.id,
        first_name: user.first_name,
        last_name: user.last_name,
        name_affix: user.name_affix,
        joined_at: joined_at
      }
    end
  end


  # This is used to determine the routes for this resource.
  # http://stackoverflow.com/a/9463495/2066546
  def self.model_name
    Group.model_name
  end

  if use_caching?
    cache :member_ids
    cache :member_table_rows
  end

end