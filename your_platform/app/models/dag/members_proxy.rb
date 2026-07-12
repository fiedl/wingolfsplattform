# A collection proxy over the members of a group, in the sense of
# ActiveRecord's CollectionProxy: it enumerates like the relation it
# wraps -- the users of the whole subtree -- and `<<` and `destroy`
# write through to the direct membership, like the former
# has_many :through association did. Returned by `group.members`.
#
class Dag::MembersProxy < Dag::CollectionProxy

  def initialize(group:, members:)
    @group = group
    super(members)
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


end
