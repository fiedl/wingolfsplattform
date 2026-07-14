# Since the materialized closure is gone, every transitive question
# walks the direct edges recursively (Dag::Traversal). The recursion
# step joins on one side of the edge and selects the other side, so a
# covering partial index per direction lets the whole walk run as
# index-only scans instead of heap fetches. valid_from/valid_to ride
# along for the membership validity walk.
#
class AddCoveringIndexesToDagLinks < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :dag_links, [:ancestor_type, :ancestor_id],
      include: [:descendant_type, :descendant_id, :valid_from, :valid_to],
      where: "direct",
      name: "dag_links_direct_walk_down",
      algorithm: :concurrently

    add_index :dag_links, [:descendant_type, :descendant_id],
      include: [:ancestor_type, :ancestor_id, :valid_from, :valid_to],
      where: "direct",
      name: "dag_links_direct_walk_up",
      algorithm: :concurrently
  end
end
