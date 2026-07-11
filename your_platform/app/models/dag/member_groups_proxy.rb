# A collection proxy over the groups a user is member of, in the
# sense of ActiveRecord's CollectionProxy: it enumerates like the
# relation it wraps -- the direct groups and their ancestors -- and
# `<<` and `destroy` write through to the direct membership, like the
# former has_many :through association did. Returned by `user.groups`.
#
class Dag::MemberGroupsProxy < SimpleDelegator

  def initialize(user:, groups:)
    @user = user
    super(groups)
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
