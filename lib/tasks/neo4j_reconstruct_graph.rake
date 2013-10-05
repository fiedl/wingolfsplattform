
namespace :neo4j do
  task reconstruct_graph: :environment do

    # This task reconstructs the whole neo4j graph database.
    # Since ALL DATA IS STORED BY ACTIVE_RECORD in the mysql database
    # and all data in the graph database is redundant, 
    # this can be done at any time.
    
    Neoid.clean_db(:yes_i_am_sure)

    Neoid.batch do
      User.all.each(&:neo_save)
      Group.all.each(&:neo_save)
      Workflow.all.each(&:neo_save)
      Page.all.each(&:neo_save)
      StructureLink.all.each(&:neo_save)
    end

  end
end
