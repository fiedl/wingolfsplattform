# -*- coding: utf-8 -*-
# This file is to be run to initialise some basic database entries, e.g. the root user group, etc.
# Execute by typing  'rake bootsrap:all'  after database migration.
# SF 2012-05-03

require 'importers/models/log'

namespace :bootstrap do

  # see: http://stackoverflow.com/questions/62201/how-and-whether-to-populate-rails-application-with-initial-data
  desc "Populate database with basic groups and pages."
  task :all => [
    'tmp:clear',
    'environment',
    'print_info',
    'basic_groups',
    'basic_nav_node_properties',
    'add_basic_pages',
    'add_help_page',
    'wbl_abo_group',
    'add_flags_to_basic_pages',
    'add_structure'
  ]

  task :print_info do
    Log.new.section "Bootstrapping: Creating basic groups and pages."
  end

  desc "Add basic groups"
  task basic_groups: :environment do
    p "Task: Add basic groups"

    # Group 'Everyone' / 'Jeder'
    Group.create_everyone_group unless Group.everyone
    Group.find_everyone_group.update_attributes( name: "Jeder" )

    # Corporations Parent Group ("Wingolf am Hochschulort")
    Group.create_corporations_parent_group unless Group.corporations_parent
    Group.find_corporations_parent_group.update_attributes( name: "Korporationen" )

    # Bvs Parent Group ("Bezirksverbände")
    Group.create_bvs_parent_group unless Group.bvs_parent
    Group.find_bvs_parent_group.update_attributes( name: "Bezirksverbände" )

  end

  desc "Set some nav node properties of the basic groups"
  task basic_nav_node_properties: :environment do
    p "Task: Set some basic nav node properties"
    n = Group.everyone.nav_node; n.slim_menu = true; n.slim_breadcrumb = true; n.hidden_menu = true; n.save; n = nil
    n = Group.corporations_parent.nav_node; n.slim_menu = true; n.slim_breadcrumb = true; n.save; n = nil
  end

  desc "Add basic pages"
  task add_basic_pages: :environment do
    p "Task: Add basic pages."
    home = Page.create_root
    home.update_attributes(title: "wingolf.org")

    mitglieder_start = Page.find_or_create_intranet_root
    mitglieder_start.update_attributes(title: "Mitglieder-Start")
    unless mitglieder_start.child_groups.include? Group.everyone
      mitglieder_start.child_groups << Group.everyone
    end
  end

  desc "Add help page"
  task add_help_page: :environment do
    p "Task: Add help page."
    help = Page.find_or_create_help_page
    help.update_attributes(title: "Hilfe")
    unless Page.find_intranet_root.child_pages.include? help
      help.parent_pages << Page.find_intranet_root
    end
  end

  task add_flags_to_basic_pages: :environment do
    p "Task: Add Flags to Basic Pages"
    Page.find_by_title( "wingolf.org" ).add_flag :root
    Page.find_by_title( "Mitglieder-Start" ).add_flag :intranet_root
    Page.find_by_title( "Hilfe" ).add_flag :help
  end

  task wbl_abo_group: :environment do
    p "Task: Adding Wingolfsblätter Abo Group"
    Group.find_or_create_wbl_abo_group
  end

  task :add_structure => [:environment] do
    p "Task: Add basic structure."
    #
    # root
    #   |--- intranet_root
    #             |----------- everyone
    #             |                |--------- corporations_parent
    #             |                |--------- bvs_parent
    #             |                |--------- hidden_users
    #             |
    #             |---------------- corporations_parent
    #             |---------------- bvs_parent
    #             |---------------- help
    #
    Page.find_root << Page.find_intranet_root
    Page.find_intranet_root << Group.find_corporations_parent_group
    Page.find_intranet_root << Group.find_bvs_parent_group
    Page.find_intranet_root << Page.find_help_page
    Page.find_intranet_root << Group.everyone
    Group.everyone << Group.find_corporations_parent_group
    Group.everyone << Group.find_bvs_parent_group
    Group.everyone << Group.hidden_users
  end


end
