# Read-write view on the members of a group: reading reaches the users
# of the whole subtree; `<<` and `destroy` operate on the direct
# membership, like the former has_many :through association did.
#
class Dag::MemberUsers < SimpleDelegator

  def initialize(group, relation)
    @group = group
    super(relation)
  end

  def <<(user)
    @group.assign_user user
  end

  def destroy(user)
    membership = Membership.with_invalid.where(ancestor_id: @group.id,
      descendant_id: user.id, direct: true).first
    raise RuntimeError, "no direct membership: user #{user.id} is only " +
      "member of group #{@group.id} through a subgroup" unless membership
    membership.destroy
  end

  def ==(other)
    return false if other.nil?
    to_a == (other.respond_to?(:to_a) ? other.to_a : other)
  end

end
