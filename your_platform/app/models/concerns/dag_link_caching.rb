concern :DagLinkCaching do

  included do
    # saved_changes, not changes: inside after_save, rails 5.2 flipped
    # `changes` to the post-save perspective, where it is always empty.
    after_save { delay_renew_cache_of_dependent_nodes if self.saved_changes.except(:needs_review, :updated_at).any? }
    after_commit :delay_renew_cache_of_dependent_nodes, on: :destroy
  end

  # Of the ancestor groups' caches, a membership change only touches
  # the ones derived from the member set. Everything else on those
  # groups -- names, breadcrumbs, map items, role caches -- only
  # changes with the group structure and keeps its cache.
  def group_caches_depending_on_memberships
    [
      :membership_ids_for_member_list,
      :memberships_for_member_list_count,
      :latest_membership_ids,
      :membership_ids_this_year,
      :member_table_rows,
      :fill_cache_for_export_lists
    ]
  end

  def fill_cache
    super
    ancestor.try(:fill_cache)
    descendant.try(:fill_cache)
  end

  # Without the materialized closure, a link change no longer touches
  # one row per ancestor group. The cache renewal fans out to the
  # ancestor groups itself: their member lists, exports, and role
  # caches depend on the subtree.
  #
  # The two changed nodes renew immediately. The fan-out to the
  # transitive ancestor groups is debounced: bulk operations -- a
  # semester's status changes, an import -- hit the same ancestor
  # groups over and over, and one renewal after the wave covers all of
  # it because the renewal recomputes from the database as it is then.
  #
  def delay_renew_cache_of_dependent_nodes
    RenewCacheJob.perform_later records: ([ancestor, descendant] - [nil]).uniq, time: Time.zone.now
    delay_renew_cache_of_ancestor_groups if ancestor.kind_of?(Group)
  end

  def delay_renew_cache_of_ancestor_groups
    membership_change = descendant.kind_of?(User)
    Rails.cache.delete "ability/wingolfiten_alive_user_ids" if membership_change

    scope = membership_change ? "memberships" : "full"
    groups = Group.where(id: Dag::Traversal.ancestor_ids_of(ancestor, type: 'Group')).to_a.select { |group|
      Rails.cache.write ["dag-ancestor-renewal-pending", group.id, scope], true,
        expires_in: 60.seconds, unless_exist: true
    }
    return if groups.empty?

    # The renewal time lies at the end of the debounce window, so the
    # job covers every change that piggybacked onto it.
    RenewCacheJob.set(wait: 60.seconds).perform_later records: groups, time: 60.seconds.from_now,
      methods: (group_caches_depending_on_memberships if membership_change)
  end

end
