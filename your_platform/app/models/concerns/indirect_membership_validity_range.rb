#
# In this project, user group memberships do not neccessarily last forever.
# They can begin at some time and end at some time. This is expressed by the
# ValidityRange of a membership.
#
# Examples:
#
#     membership.valid_from  # =>  time
#     membership.valid_to    # =>  time
#     membership.invalidate
#
# Scopes:
#
#     Membership.with_invalid
#     Membership.only_valid
#     Membership.only_invalid
#     Membership.at_time(time)
#
# By default, the `only_valid` scope is applied, i.e. only memberships are
# found that are valid at present time. To override this scope, use either
# `with_invalid` or `unscoped`.
#
concern :IndirectMembershipValidityRange do

  included do
    # The `becomes` part is needed for serialization, because this is also
    # executed for subclasses like `Memberships::Status`.
    after_save { RecalculateIndirectMembershipsJob.perform_later(self.becomes(self.type.constantize)) if self.direct? }
  end


  # Validity Range Attributes
  # ====================================================================================================

  # The validity range attributes are inherited for indirect memberships.
  #
  #       *-----------------(c)--------------------*
  #                          |
  #                |--------------------|
  #                |                    |
  #       *-------(a)--------*          |
  #                          *---------(b)---------*
  #
  #       _________________________________________________________
  #       t1                 t2                    t3      time -->
  #
  # If membership A is valid from t1 to t2 and membership B is valid from t2 to t3
  # and membership C is the indirect membership that results from the memberships
  # A and B, then C is valid from t1 to t3.
  #
  # This means that the valid_from attribute is derived from the valid_from attribute
  # of the earliest direct membership. The valid_to attribute is derived from the
  # latest direct membership.
  #
  def earliest_direct_membership
    @earliest_direct_membership ||= Membership.with_invalid.find(earliest_direct_membership_id) if earliest_direct_membership_id
  end
  def earliest_direct_membership_id
    # NULLS FIRST, like mysql sorted: a nil valid_from counts as earliest.
    direct_memberships(with_invalid: true).reorder(Arel.sql('(valid_from IS NOT NULL) ASC, valid_from ASC')).pluck(:id).first
  end

  def latest_direct_membership
    @latest_direct_membership ||= direct_memberships.only_valid.last
    # NULLS LAST, like mysql sorted this descending ordering.
    @latest_direct_membership ||= direct_memberships(with_invalid: true).reorder(Arel.sql('(valid_to IS NOT NULL) DESC, valid_to DESC')).first
  end


  # This method recalculates the validity range for an indirect membership.
  # This becomes necessary whenever the validity range of a direct membership is changed, so that
  # the validity range of the indirect memberships can be used in database queries,
  # for example, when using scopes.
  #
  # **Attention**: At this point, this mechanism does not cover the validity range of
  # indirect memberships where there should be a gap in the membership:
  #
  #     *----------*     *----------* (indirect membership with gap in validity range)
  #          |--------|--------|
  #     *----------*           |      (direct membership 1)
  #                      *----------* (direct membership 2)
  #
  # TODO: This has to be fiexed, probably when switching to neo4j.
  #
  def recalculate_validity_range_from_direct_memberships
    unless direct?
      self.valid_from = earliest_direct_membership.try(:valid_from)
      self.valid_to = latest_direct_membership.try(:valid_to)
    end
  end

  def recalculate_indirect_validity_ranges
    if self.direct?
      # The materialized rows, not the derived IndirectMembership
      # objects: this maintenance keeps the rows in sync as long as
      # the closure is still written.
      Membership.with_invalid.where(direct: false, descendant_id: descendant_id,
        ancestor_id: group.ancestor_group_ids).each do |indirect_membership|
        indirect_membership.recalculate_validity_range_from_direct_memberships
        indirect_membership.save
      end
    end
  end

  def recalculate_validity_range
    if self.direct?
      self.recalculate_indirect_validity_ranges
    else
      self.recalculate_validity_range_from_direct_memberships
      self.save
    end
  end

  def recalculate
    recalculate_validity_range
  end


  # Invalidation
  # ====================================================================================================

  # For indirect memberships, invalidation is not possible.
  # Only direct memberships can be invalidated. The validity of the indirect memberships
  # inherts from the direct ones.
  #
  def make_invalid(time = Time.zone.now)
    raise RuntimeError, 'An indirect membership cannot be invalidated. ' + self.user.id.to_s + ' ' + self.group.id.to_s unless direct?
    super
  end

end
