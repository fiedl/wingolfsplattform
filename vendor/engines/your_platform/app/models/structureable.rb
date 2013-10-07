# -*- coding: utf-8 -*-

# This module provides the ActiveRecord::Base extension `is_structureable`, which characterizes
# a model as part of the global dag_link structure in this project. All structureable objects
# are nodes of this dag link.
# 
# Examples: 
#     @page1.parent_pages << @page2
#     @page1.parents # => [ @page2, ... ]
#     
#     @group.child_users << @user
#     @group.children # => [ @user, ... ]
#     @user.parents # => [ @group, ... ]
# 
# For all methods that are provided, please consult the documentations of the 
# `acts-as-dag` gem and of the `acts_as_paranoid_dag` gem.
# 
# This module is included in ActiveRecord::Base via an initializer at
# config/initializers/active_record_structureable_extension.rb
#
module Structureable

  # options: ancestor_class_names, descendant_class_names

  # This method is used to declare a model as structureable, i.e. part of the global 
  # dag link structure. 
  # 
  # Options:
  #   ancestor_class_names
  #   descendant_class_names
  # 
  # Example:
  #     class Group < ActiveRecord::Base
  #       is_structureable ancestor_class_names: %w(Group), descendant_class_names: %w(Group User)
  #     end
  #     class User < ActiveRecord::Base
  #       is_structureable ancestor_class_names: %w(Group)
  #     end
  # 
  def is_structureable( options = {} )
    
    include Neoid::Node

    # StructureLinks (direct relationships between strcturable objects) are stored
    # via ActiveRecord in the mysql database. (The neo4j database contains only 
    # redundant information and is used for fast queries.)
    #
    has_many :links_as_parent, foreign_key: :parent_id, class_name: 'StructureLink'
    has_many :links_as_child, foreign_key: :child_id, class_name: 'StructureLink'
    
    # For all class names that are provided by 
    # TODO: CORRECT OPTIONS 
    # provide polymorphic associations (via ActiveRecord).
    # 
    # Examples:
    #   user.links_as_child_for_groups
    #   user.parent_groups
    #   group.links_as_parent_for_users
    #   group.child_users
    # 
    parent_class_names = options[:ancestor_class_names] || []
    child_class_names = options[:descendant_class_names] || []

    parent_class_names.each do |parent_class_name|
      has_many( "links_as_child_for_#{parent_class_name.underscore.pluralize}".to_sym, 
                as: :child, class_name: 'StructureLink', 
                conditions: { parent_type: parent_class_name } )
      has_many( "parent_#{parent_class_name.underscore.pluralize}".to_sym, 
                through: "links_as_child_for_#{parent_class_name.underscore.pluralize}".to_sym, 
                as: :structureable, 
                foreign_key: :parent_id, source: 'parent', 
                source_type: parent_class_name )
      define_method "ancestor_#{parent_class_name.underscore.pluralize}".to_sym do
        send("parent_#{parent_class_name.underscore.pluralize}".to_sym)
      end
    end  

    child_class_names.each do |child_class_name|
      has_many( "links_as_parent_for_#{child_class_name.underscore.pluralize}".to_sym, 
                as: :parent, class_name: 'StructureLink', 
                conditions: { child_type: child_class_name } )
      has_many( "child_#{child_class_name.underscore.pluralize}".to_sym, 
                through: "links_as_parent_for_#{child_class_name.underscore.pluralize}".to_sym, 
                as: :structureable, 
                foreign_key: :child_id, source: 'child', 
                source_type: child_class_name )
      define_method "descendant_#{child_class_name.underscore.pluralize}".to_sym do
       send("child_#{child_class_name.underscore.pluralize}".to_sym)
      end
    end
    
    # Attributes that are copied over to the neo4j nodes.
    # These attributes are accessible in the neo4j graph queries.
    #
    neoidable do |c|
      c.field :name
      c.field :title
    end
    
    before_destroy   :destroy_links

    # see Flagable model.
    has_many_flags

    # Structureable objects may have special_groups as descendants, e.g. the admins_parent group.
    # This mixin loads the necessary methods to interact with them.
    #
    include StructureableMixins::HasSpecialGroups

    include StructureableInstanceMethods
  end

  module StructureableInstanceMethods

    # Overriding the neo_node method ensures that for STI the same neo_node
    # is returned for the same object regardless of the subclass.
    # 
    # That means: page.neo_node == page.becomes(BlogPost).neo_node
    #
    def neo_node
      super || self.becomes(self.class.base_class).neo_node
    end

    # The unique id of the neo4j node that corresponds to the
    # strucureable object.
    #
    def neo_id
      neo_node.try(:neo_id)
    end
    
    # Use neo4j for graph queries.
    #
    def parents
      find_related_nodes_via_cypher("
        match (parents)-[:is_parent_of]->(self)
        return parents
      ")
    end
    def children
      find_related_nodes_via_cypher("
        match (self)-[:is_parent_of]->(children)
        return children
      ")
    end
    def ancestors
    end
    def descendants
    end
    
    def find_related_nodes_via_cypher(query_string)
      query_string = "
        start self=node(#{neo_id})
        #{query_string}
      "
      cypher_results_to_objects(
        Neoid.db.execute_query(query_string)
      )
    end
    
    def cypher_results_to_objects(cypher_results)
      cypher_results["data"].collect do |result|
        result.first["data"]["ar_type"].constantize.find(result.first["data"]["ar_id"])
      end
    end
    

    # Include Rules, e.g. let this object have admins.
    # 
    include StructureableMixins::Roles

    # When a dag node is destroyed, also destroy the corresponding dag links.
    # Otherwise, there would remain ghost dag links in the database that would
    # corrupt the integrity of the database. 
    # 
    # If the database gets ever messed up like this, delete the concerning
    # *direct* dag links by hand and then run this rake task to re-create
    # the indirect dag links:
    # 
    #    rake reconstruct_indirect_dag_links:all
    # 
    def destroy_dag_links

      # # destory only child and parent links, since the indirect links
      # # are destroyed automatically by the DagLink model then.
      # links = self.links_as_parent + self.links_as_child 
      # 
      # for link in links do
      # 
      #   if link.destroyable?
      #     link.destroy
      #   else
      # 
      #     # In facty, all these links should be destroyable. If this error should
      #     # be raised, something really went wrong. Please send in a bug report then
      #     # at http://github.com/fiedl/your_platform.
      #     raise "Could not destroy dag links of the structureable object that should be deleted." +
      #       " Please send in a bug report at http://github.com/fiedl/your_platform."
      #     return false
      #   end  
      # 
      # end  
    end

    def destroy_links
      self.destroy_dag_links
    end

  end

end
