# -*- coding: utf-8 -*-

# This module provides the ActiveRecord::Base extension `is_structureable`, which characterizes
# a model as part of the global graph structure in this project. All structureable objects
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
# This module is included in ActiveRecord::Base via an initializer at
# config/initializers/active_record_structureable_extension.rb
#
module Structureable

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
      find_related_nodes_via_cypher("
        match (ancestors)-[:is_parent_of*0..100]->(self)
        return ancestors
      ").uniq
    end
    def descendants
      find_related_nodes_via_cypher("
        match (self)-[:is_parent_of*0..100]->(descendants)
        return descendants
      ").uniq
    end
    
    # This method returns all ActiveRecord objects found by a cypher
    # neo4j query defined through the given query_string.
    # 
    # Within the query_string, no START expression is needed, 
    # because the start node is given by the neo_node of this
    # structureable object. It is referred to just by 'self'. 
    #
    # Example:
    #   group.find_related_nodes_via_cypher("
    #     match (self)-[:is_parent_of]->(children)
    #     return children
    #   ")  # =>  [child_group1, child_group2, ...]
    #
    def find_related_nodes_via_cypher(query_string)
      query_string = "
        start self=node(#{neo_id})
        #{query_string}
      "
      cypher_results_to_objects(
        Neoid.db.execute_query(query_string)
      )
    end
    
    # This method returns the ActiveRecord objects that match the
    # given cypher query result. 
    # 
    # For an example, have a look at the method
    #   find_related_nodes_via_cypher.
    #
    def cypher_results_to_objects(cypher_results)
      cypher_results["data"].collect do |result|
        result.first["data"]["ar_type"].constantize.find(result.first["data"]["ar_id"])
      end
    end
    private :cypher_results_to_objects
    

    # Include Rules, e.g. let this object have admins.
    # 
    include StructureableMixins::Roles

    # When a graph node is destroyed, also destroy the corresponding links.
    # Otherwise, there would remain ghost links in the database.
    # 
    # If the database gets ever messed up, it can be re-constructed using 
    # this rake task:
    #
    #    # bash 
    #    bundle exec rake neo4j:neo4j_reconstruct_graph
    # 
    def destroy_dag_links
      for link in (self.links_as_parent + self.links_as_child) do
        link.destroy
      end  
    end

    def destroy_links
      self.destroy_dag_links
    end

  end

end
