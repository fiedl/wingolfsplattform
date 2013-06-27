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
    
    def navable?
      is_navable?
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
      children.select { |child| child.respond_to? :nav_node }
    end

    private

  end
end

