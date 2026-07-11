# Read-write view on the groups a user is member of: reading includes
# the ancestor groups of his direct memberships; `<<` and `destroy`
# operate on the direct membership, like the former has_many :through
# association did.
#
class Dag::MemberGroups < SimpleDelegator

  def initialize(user, relation)
    @user = user
    super(relation)
  end

  def <<(group)
    group.assign_user @user
  end

  def destroy(group)
    membership = Membership.with_invalid.where(ancestor_id: group.id,
      descendant_id: @user.id, direct: true).first
    raise RuntimeError, "no direct membership: user #{@user.id} is only " +
      "member of group #{group.id} through a subgroup" unless membership
    membership.destroy
  end

  def ==(other)
    return false if other.nil?
    to_a == (other.respond_to?(:to_a) ? other.to_a : other)
  end

end
