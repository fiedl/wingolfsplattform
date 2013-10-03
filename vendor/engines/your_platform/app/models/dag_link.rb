# -*- coding: utf-8 -*-
class DagLink < ActiveRecord::Base
  #attr_accessible :ancestor_id, :ancestor_type, :count, :descendant_id, :descendant_type, :direct
  #acts_as_dag_links polymorphic: true, paranoid: true
  
  belongs_to :parent, polymorphic: true
  belongs_to :child, polymorphic: true
    
  include Neoid::Relationship
  
  neoidable do |c|
    c.relationship start_node: :parent, end_node: :child, type: :is_parent_of
  end

end
