# -*- coding: utf-8 -*-

# This extends the your_platform Group model.
require_dependency YourPlatform::Engine.root.join( 'app/models/group' ).to_s

# This class represents a group of the platform.
# While the most part of the group class is contained in the your_platform engine,
# this re-opened class contains all wingolf-specific additions to the group model.

class Group

  # Associated Objects
  # ==========================================================================================
  
  # Just the German-named alias method for officers of the group.
  # 
  def amtsträger
    officers
  end


  # Special Groups
  # ==========================================================================================

  # German Translations
  # ------------------------------------------------------------------------------------------

  # TODO: delete this
  def self.jeder
    self.find_everyone_group
  end
  
  def self.wingolf_am_hochschulort
    self.corporations_parent
  end

  
  # BVs
  # ------------------------------------------------------------------------------------------

  def self.bvs_parent
    self.find_bvs_parent_group
  end

  def self.bvs
    self.find_bv_groups
  end

  def self.find_bvs_parent_group
    Group.find_by_flag( :bvs_parent )
  end

  def self.find_bv_groups
    self.find_bvs_parent_group.child_groups
  end

  def self.create_bvs_parent_group
    bvs_parent = Group.create( name: "Bezirksverbände" )
    bvs_parent.add_flag( :bvs_parent )
    bvs_parent.parent_groups << Group.everyone
    bvs_parent.name = I18n.translate( :bvs_parent ) # "Bezirksverbände"
    bvs_parent.save
    return bvs_parent
  end


  
  # Finder Methods
  # ==========================================================================================

  def self.find_wah_groups_of( user )
    ancestor_groups = user.ancestor_groups
    wah_groups = Group.wingolf_am_hochschulort.child_groups if Group.wingolf_am_hochschulort
    return ancestor_groups & wah_groups if ancestor_groups and wah_groups
  end

  def self.find_wah_branch_groups_of( user )
    ancestor_groups = user.ancestor_groups
    wah_branch = Group.wingolf_am_hochschulort.descendant_groups if Group.wingolf_am_hochschulort
    return ancestor_groups & wah_branch if ancestor_groups and wah_branch
  end

  def self.find_non_wah_branch_groups_of( user )
    ancestor_groups = user.ancestor_groups
    wah_branch = Group.wingolf_am_hochschulort.descendant_groups if Group.wingolf_am_hochschulort
    wah_branch = [] unless wah_branch
    return ancestor_groups - wah_branch
  end




end

