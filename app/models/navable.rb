# -*- coding: utf-8 -*-
# Dieses Modul stellt die Methode +is_navable+ für ActiveRecord::Base zur Verfügung.
# Damit kann ein Model (User, Page, ...) als navigationsfähig (d.h. mit Menü-Elementen, Breadcrumb, etc.)
# deklariert werden.
# Die Einbindung dieses Moduls erfolgt in einem Initializer: config/initializers/active_record_navable_extension.rb.
module Navable
  def is_navable
    has_one                :nav_node, as: :navable, dependent: :destroy, autosave: true
    
    include InstanceMethodsForNavables
  end
  module InstanceMethodsForNavables
    def is_navable? 
      true
    end

    def nav_node
      node = super
      node = build_nav_node unless node
      return node
    end

    def navnode
      nav_node
    end

    def nav
      nav_node
    end

    def navable_children
      #children.select{ |child| child.respond_to? :nav_node } # inefficient!
      self.links_as_parent.where( 'descendant_type != ?', 'User' ).where( direct: true ).collect { |link| link.descendant }
      #children.where( 'descendant_type != ?', 'User' ) # suppress users -- they don't have to be in the menus
    end

    private

  end
end

