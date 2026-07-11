# Read-write view on the users of a special group, e.g. `page.guests`:
# reading reaches all descendant users (the special group may have
# subgroups like regular_guests/vip_guests); pushing adds a direct
# child user, like pushing to the former has_many :through association
# `special_group.descendant_users` did.
#
class Dag::SpecialGroupUsers < SimpleDelegator

  def initialize(group)
    @group = group
    super(group.descendant_users)
  end

  def <<(user)
    @group.child_users << user
  end

  def ==(other)
    return false if other.nil?
    to_a == (other.respond_to?(:to_a) ? other.to_a : other)
  end

end
