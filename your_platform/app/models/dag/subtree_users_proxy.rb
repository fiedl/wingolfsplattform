# A collection proxy over the users of a group's subtree, in the sense
# of ActiveRecord's CollectionProxy: it enumerates like the relation it
# wraps, and `<<` writes through -- adding a direct child user, like
# pushing to the former has_many :through association did.
#
# Returned by special group accessors such as `page.guests`, whose
# subtree may contain subgroups like regular_guests/vip_guests.
#
class Dag::SubtreeUsersProxy < SimpleDelegator

  def initialize(ancestor_group:)
    @ancestor_group = ancestor_group
    super(ancestor_group.descendant_users)
  end

  def <<(user)
    @ancestor_group.child_users << user
  end

  def ==(other)
    return false if other.nil?
    to_a == (other.respond_to?(:to_a) ? other.to_a : other)
  end

end
