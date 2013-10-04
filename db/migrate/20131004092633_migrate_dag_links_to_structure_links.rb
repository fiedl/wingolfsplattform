class MigrateDagLinksToStructureLinks < ActiveRecord::Migration
  
  # This migrates from the dag_links table, which is used by the acts-as-dag gem, 
  # to the structure_links table, which is used by neo4j (neoid gem).
  #
  def up
    
    # remove all indirect links since they are not needed for traversing
    # in neo4j. If we would keep those, neo4j would interpret them as direct links.
    #
    execute "DELETE FROM dag_links WHERE direct = false"
    
    # drop colums that are not needed anymore, since we're using neo4j now
    # rather than the acts-as-dag gem.
    #
    remove_column :dag_links, :direct
    remove_column :dag_links, :count

    # rename the table to reflect the models (Structureable) that are connected
    # by these links rather than the technology. Furthermore with the migration
    # to neo4j this is not a DAG anymore, but a DG. 
    # D = directed, A = acyclic, G = graph.
    #
    rename_table :dag_links, :structure_links
    
    # rather than using paranoid (soft deletion) and thereby using created_at and
    # deleted_at, we assign valid_from and valid_to attributes to relationships,
    # now. Thereby, one can also have relationships that are always valid. 
    #
    # For Group-User relationships, we need to copy the created_at value to the
    # valid_from value in order not to lose this information.
    #
    add_column :structure_links, :valid_from, :datetime
    rename_column :structure_links, :deleted_at, :valid_to
    execute "UPDATE structure_links SET valid_from=created_at WHERE parent_type='Group' AND child_type='User'"

    # If one has got existing data, one has to copy this to the graph database.
    # Since ALL DATA IS STORED BY ACTIVE_RECORD and all data in the graph database
    # is redundant using the neoid gem, this task can be executed at any time:
    #
    p "Migrating to neo4j. If you have existing data, migrate it using:"
    p "  bundle exec rake neo4j:reconstruct_graph"
    
  end

  def down
    
    rename_table :structure_links, :dag_links
    add_column :dag_links, :direct, :boolean
    add_column :dag_links, :count, :integer
    rename_column :dag_links, :valid_to, :deleted_at
    execute "UPDATE dag_links SET created_at=valid_from WHERE parent_type='Group' AND child_type='User'"
    remove_column :dag_links, :valid_from
        
    p "ATTENTION:"
    p "This migrates from neo4j to the acts-as-dag gem."
    p "Please generate indirect links by"
    p "  bundle exec rake reconstruct_indirect_dag_links:all"
    
  end
end
