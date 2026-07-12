class DagLink < ApplicationRecord

  acts_as_dag_links polymorphic: true

  def title
    "Link #{ancestor_type} #{ancestor_id} --> #{descendant_type} #{descendant_id}"
  end

  # All ids reachable from the given start nodes by walking links
  # between nodes of the same type only, breadth first, excluding the
  # start ids. Unlike Dag::Traversal, paths crossing other node types,
  # e.g. Group→Page→Group, are not followed -- matching the former
  # neo4j HAS_SUBGROUP*/HAS_SUBPAGE* traversal.
  #
  def self.descendant_ids_through_same_type(type, start_ids)
    descendant_ids = []
    frontier_ids = start_ids
    while frontier_ids.any?
      frontier_ids = where(direct: true, ancestor_type: type, descendant_type: type,
        ancestor_id: frontier_ids).pluck(:descendant_id).uniq - descendant_ids - start_ids
      descendant_ids += frontier_ids
    end
    descendant_ids
  end

  include DagLinkTypes
  include DagLinkCaching if use_caching?

end
