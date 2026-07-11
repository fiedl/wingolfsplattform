concern :DagLinkCaching do

  included do
    after_save { delay_renew_cache_of_dependent_nodes if self.changes.except(:needs_review, :updated_at).any? }
    after_commit :delay_renew_cache_of_dependent_nodes, on: :destroy
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
  def delay_renew_cache_of_dependent_nodes
    nodes = [ancestor, descendant] - [nil]
    if ancestor.kind_of?(Group)
      nodes += Group.where(id: Dag::Query.ids(ancestor, direction: :ancestor, type: 'Group')).to_a
    end
    RenewCacheJob.perform_later nodes.uniq, time: Time.zone.now
  end

end
