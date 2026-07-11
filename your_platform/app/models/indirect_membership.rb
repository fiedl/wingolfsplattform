# The membership of a user in a group somewhere above the groups he
# directly belongs to, e.g. in the corporation above his status group.
#
# Indirect memberships are not stored; they derive from the direct
# membership rows along the paths between group and user
# (Dag::Traversal.membership_validity_ranges). A user can have several
# validity ranges: leaving in 2010 and rejoining in 2015 gives two,
# and the span between them counts as not-a-member -- unlike the
# former materialized indirect rows, which only stored the min/max
# envelope.
#
class IndirectMembership

  attr_reader :group, :user

  def initialize(group, user, validity_ranges: nil)
    @group = group
    @user = user
    @validity_ranges = validity_ranges
  end

  # The time ranges over which the user is a member of the group, one
  # per continuous span of subtree membership. Beginless or endless
  # where the membership is unbounded.
  def validity_ranges
    @validity_ranges ||= Dag::Traversal.membership_validity_ranges(group, user)
  end

  def present?
    validity_ranges.any?
  end

  # The envelope bounds, for display compatibility with the former
  # materialized rows: first joined, last left (nil if still member).
  def valid_from
    validity_ranges.first.try(:begin)
  end

  def valid_to
    validity_ranges.last.try(:end) if validity_ranges.none? { |range| range.end.nil? }
  end

  def valid_at?(time)
    validity_ranges.any? { |range| range.cover?(time) }
  end

  def currently_valid?
    valid_at? Time.zone.now
  end

  def valid_from_localized_date
    valid_from ? I18n.localize(valid_from.to_date) : ""
  end

  def valid_to_localized_date
    valid_to ? I18n.localize(valid_to.to_date) : ""
  end

  def direct?
    false
  end

  def can_be_invalidated?
    false
  end

  def readonly?
    true
  end

  def id
    nil
  end

  def user_id
    user.id
  end

  def group_id
    group.id
  end

  def user_title
    user.try(:title)
  end

  def title
    I18n.translate :membership_of_user_in_group, user_name: user.title, group_name: group.name
  end

  def direct_memberships(options = {})
    group_ids = [group.id] + group.descendant_group_ids
    memberships = Membership
    memberships = memberships.with_invalid if options[:with_invalid] || valid_to
    memberships.find_all_by_user(user).where(direct: true, ancestor_id: group_ids, ancestor_type: 'Group').order('valid_from')
  end

  def direct_memberships_now_and_in_the_past
    direct_memberships with_invalid: true
  end

  def direct_groups
    direct_memberships.collect(&:group)
  end

  def corporation
    ((group.ancestor_groups + [group]) && user.corporations).first if group && user
  end

  def ==(other)
    other.kind_of?(IndirectMembership) && other.group == group && other.user == user
  end

end
