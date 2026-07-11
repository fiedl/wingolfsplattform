# The materialized closure rows (direct: false) are not written or read
# anymore; all transitive questions are answered by recursive CTEs over
# the direct links. This deletes the stale rows, keeping an archive
# table as rollback insurance for one release.
# https://github.com/fiedl/wingolfsplattform/issues/129
#
class DeleteMaterializedIndirectDagLinks < ActiveRecord::Migration[5.0]
  def up
    # Review markers move onto the earliest direct membership they
    # derive from, so the review intent survives the row deletion.
    # (All membership flags carry flagable_type 'DagLink'.)
    say_with_time "moving review flags of indirect rows to direct memberships" do
      moved = 0
      DagLink.unscoped.where(direct: false)
        .joins("JOIN flags ON flags.flagable_type = 'DagLink' AND flags.flagable_id = dag_links.id")
        .distinct.each do |row|
        subtree_group_ids = [row.ancestor_id] + Dag::Traversal.descendant_ids(of_type: 'Group',
          of_ids: [row.ancestor_id], type: 'Group')
        target = DagLink.unscoped.where(direct: true, descendant_type: 'User',
          descendant_id: row.descendant_id, ancestor_type: 'Group', ancestor_id: subtree_group_ids)
          .reorder(Arel.sql('valid_from NULLS FIRST')).first
        row.flags.each do |flag|
          if target && !Flag.where(flagable_type: 'DagLink', flagable_id: target.id, key: flag.key).exists?
            flag.update_columns flagable_id: target.id
            moved += 1
          else
            flag.delete
          end
        end
      end
      moved
    end

    # connection.execute, not the bare migration execute: rake loads
    # lib/tasks/import.rake, which defines a global `execute` method
    # that would swallow these statements silently.
    say_with_time "archiving and deleting the indirect rows" do
      connection.execute "CREATE TABLE dag_links_indirect_archive AS SELECT * FROM dag_links WHERE direct = FALSE"
      connection.execute("DELETE FROM dag_links WHERE direct = FALSE").cmd_tuples
    end

    change_column_default :dag_links, :direct, true
    remove_column :dag_links, :count
  end

  def down
    add_column :dag_links, :count, :integer
    change_column_default :dag_links, :direct, nil
    # Explicit column lists: the re-added count column sits at the end
    # of dag_links now, but the archive preserves the original order.
    columns = "id, ancestor_id, ancestor_type, descendant_id, descendant_type, " +
      "direct, count, created_at, updated_at, valid_to, valid_from, type"
    connection.execute <<~SQL
      INSERT INTO dag_links (#{columns})
      SELECT #{columns} FROM dag_links_indirect_archive
    SQL
    drop_table :dag_links_indirect_archive
  end
end
