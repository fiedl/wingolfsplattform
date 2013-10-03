class RenameColumnsInDagLinks < ActiveRecord::Migration
  def up
    rename_column :dag_links, :ancestor_id, :parent_id
    rename_column :dag_links, :ancestor_type, :parent_type
    rename_column :dag_links, :descendant_id, :child_id
    rename_column :dag_links, :descendant_type, :child_type
  end

  def down
    rename_column :dag_links, :parent_id, :ancestor_id
    rename_column :dag_links, :parent_type, :ancestor_type
    rename_column :dag_links, :child_id, :descendant_id
    rename_column :dag_links, :child_type, :descendant_type
  end
end
