# -*- coding: utf-8 -*-
#
# This module provides the +is_navable+ method for ActiveRecord::Base.
# Calling this method marks the model (User, Page, ...) as navable, i.e. has menu, breadcrumbs, etc. 
#
# The inclusion in ActiveRecord::Base is done in
# config/initializers/active_record_navable_extension.rb.
#

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

    def cached_breadcrumbs
      breadcrumbs_navables = Rails.cache.fetch("breadcrumbs_navables") { [] }
      breadcrumbs_navables << self unless breadcrumbs_navables.include? self
      Rails.cache.write("breadcrumbs_navables", breadcrumbs_navables)
      Rails.cache.fetch([self, "breadcrumbs"]) { nav_node.breadcrumbs }
    end

    def self.delete_cached_breadcrumbs
      breadcrumbs_navables = Rails.cache.fetch("breadcrumbs_navables") { [] }
      breadcrumbs_navables.collect do |navable|
        Rails.cache.delete([navable, "breadcrumbs"])
      end
      Rails.cache.delete("breadcrumbs_navables")
    end

    def cached_ancestor_navables
      ancestor_navables_navables = Rails.cache.fetch("ancestor_navables_navables") { [] }
      ancestor_navables_navables << self unless ancestor_navables_navables.include? self
      Rails.cache.write("ancestor_navables_navables", ancestor_navables_navables)
      Rails.cache.fetch([self, "ancestor_navables"]) { nav_node.ancestor_navables }
    end

    def self.delete_cached_ancestor_navables
      ancestor_navables_navables = Rails.cache.fetch("ancestor_navables_navables") { [] }
      ancestor_navables_navables.collect do |navable|
        Rails.cache.delete([navable, "ancestor_navables"])
      end
      Rails.cache.delete("ancestor_navables_navables")
    end

    def self.delete_cache
      self.delete_cached_breadcrumbs
      self.delete_cached_ancestor_navables
    end

    private

  end
end
