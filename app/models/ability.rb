# This class defines the authorization rules.
# It uses the 'cancan' gem: https://github.com/ryanb/cancan
#
# ATTENTION: This class definition below overrides the your_platform rules, which can be found at:
# https://github.com/fiedl/your_platform/blob/master/app/models/ability.rb
#
require_dependency YourPlatform::Engine.root.join('app/models/ability').to_s

module AbilityDefinitions
  
  # Define yoyur abilities below in the appropriate sections.
  # If you want to circumvent the authorization process from your_platform
  # including role preview etc., you can override the `initialize` method:
  #
  #   def initialize(user, params = {}, options = {})
  #     user.try(:admin?)
  #       can :manage, all
  #     else
  #       can :read, :all
  #     end
  #   end
  #
  #
  # ATTENTION: Do not use `can :read, :all` anymore.
  # Anything that can be read has to be specified explicitely.
  #
  # Also, use the `cannot` method with care.
  # If you define
  # 
  #     def rights_for_global_admins
  #       can :manage, :all
  #     end
  #     def rights_for_signed_in_users
  #       cannot :destroy, Group
  #     end
  # 
  # then global admins cannot destroy groups, since they
  # are also signed-in users.
  #
  # You should have a quick look at the original `initialize` method.
  # https://github.com/fiedl/your_platform/blob/master/app/models/ability.rb
  #

  # ===============================================================================================
  # Local admins can manage their groups, this groups' subgroups 
  # and all users within their groups. They can also execute workflows.
  #
  def rights_for_local_admins
    if not read_only_mode?
      can :update, Group do |group|
        group.admins_of_self_and_ancestors.include?(user)
      end
      can :rename, Group do |group|
        group.admins_of_self_and_ancestors.include?(user) and
        
        # local admins cannot rename groups with flags or corporations.
        #
        not (group.flags.present? || group.corporation?)
      end
      can :change_internal_token, Group do |group|
        group.admins_of_self_and_ancestors.include?(user)
      end
      # cannot :change_token, Group
      can :update_memberships, Group do |group|
        group.admins_of_self_and_ancestors.include?(user) and
        
        # only global admins are allowed to manage local admins.
        #
        not group.has_flag?(:admins_parent)
      end
      can :create_memberships, Group do |group|
        can? :update, group
      end
      # cannot :create_officers_group_for, Group
      can :destroy, Group do |group|
        group.admins_of_self_and_ancestors.include?(user) and
        
        # One can't destroy a group with members.
        group.descendant_users.count > 0
      end
      
      can :manage, User, id: Role.of(user).administrated_users.map(&:id)
      can :manage, UserAccount, user_id: Role.of(user).administrated_users.map(&:id)

      can :execute, Workflow do |workflow|
        # Local admins can execute workflows of groups they're admins of.
        # And they can execute the mark_as_deceased workflow, which is a global workflow.
        # if they do administrate a group.
        #
        (workflow == Workflow.find_mark_as_deceased_workflow) ||
          workflow.admins_of_ancestors.include?(user)
      end

      can :manage, Page do |page|
        page.admins_of_self_and_ancestors.include? user
      end

      can :manage, ProfileField do |profile_field|
        profile_field.profileable.nil? ||  # in order to create profile fields
          can?(:update, profile_field.profileable)
      end
      can :manage, UserGroupMembership do |membership|
        can? :update, membership.user
      end
      can :create, :aktivmeldung do
        user.administrated_aktivitates.count > 0
      end
    end
  end
  
  # ===============================================================================================
  def rights_for_signed_in_users
    #
    # Inherited from your_platform:
    # - terms of use
    # - users
    #   - name auto completion
    #   - read the own user profile
    #   - read all non-hidden user profiles
    # - manage own non-general profile fields
    # - set validity ranges on own memberships (for corporate vita)
    # - join events
    # - read groups that are not former-member groups
    # - read pages of own groups
    # - download attachements of those pages
    # 
    super
    
    # For the moment, everybody can view the statistics.
    #
    can :index, :statistics
    can :read, :statistics
    can :export, :statistics
    
    if not read_only_mode?
      # Regular users can update their own profile.
      # They can change their first but not their surnames.
      #
      can [:update, :change_first_name, :change_alias], User, :id => user.id
      
      can :update, UserAccount, :user_id => user.id
    end
    
    can :read, ProfileField do |profile_field|
      # Some profile fields have parent profile fields.
      # They determine what kind of profile field this is.
      parent_field = profile_field
      while parent_field.parent != nil do
        parent_field = parent_field.parent
      end
      
      # Regular users can read profile fields of profiles they are allowed to see.
      # Exceptions below.
      #
      can?(:read, profile_field.profileable) and
      
      # Regular users can only see their own bank accounts
      # as well as bank accounts of non-user objects, i.e. groups.
      #
      not ((parent_field.type == 'ProfileFieldTypes::BankAccount') &&
        parent_field.profileable.kind_of?(User) && (parent_field.profileable.id != user.id))
    end
    
    # # TODO: Wieder aktivieren, falls man die übrigen General-Felder bearbeiten können soll.
    # # Im Moment können (per your_platform) die Benutzer nur ihre Nicht-General-Felder bearbeiten.
    #
    # if not read_only_mode?
    #   # Regular users can create, update or destroy own profile fields.
    #   # Exceptions:
    #   #   They cannot change their membership number.
    #   #
    #   can [:create, :read, :update, :destroy], ProfileField do |field|
    #     field.profileable.nil? || ((field.label != 'W-Nummer') && (field.profileable == user))
    #   end
    # end
    
    # List exports
    #   - BV-Mitgliedschaft berechtigt dazu, die Mitglieder dieses BV
    #       zu exportieren.
    #   - Mitgliedschaft in einer Verbindung als Bursch oder Philister
    #       berechtigt dazu, die Mitglieder dieser Verbindung zu
    #       exportieren.
    #   - Normale Gruppen-Mitgliedschaften (etwa Gruppe 'Jeder' 
    #       oder 'Wingolfsblätter-Abonnenten') berechtigen nicht zum
    #       Export.
    #
    can :export_member_list, Group do |group|
      if group.bv?
        user.in? group.members
      elsif group.corporation
        user.in?(group.corporation.philisterschaft.members) or 
        user.in?(group.corporation.descendant_groups.where(name: 'Burschen').first.members)
      else
        false
      end
    end
  end
  
  # ===============================================================================================
  # Local officers can export the member lists of their groups.
  #
  def rights_for_local_officers
    #
    # Inherited from your_platform:
    # - export member list for groups the user is officer of
    # - sending group mails
    # - creating events
    # 
    super
    
    if not read_only_mode?
      # Create, update and destroy Pages
      #
      can :create_page_for, [Group, Page] do |parent|
        parent.officers_of_self_and_ancestors.include?(user)
      end
      can :update, Page do |page|
        (page.author == user) && (page.group) && (page.group.officers_of_self_and_ancestors.include?(user))
      end
      can :destroy, Page do |page|
        can? :update, page
      end
      
      # Create, update and destroy Attachments
      #
      can :create_attachment_for, Page do |page|
        (page.group) && (page.group.officers_of_self_and_ancestors.include?(user))
      end
      can :update, Attachment do |attachment|
        (attachment.parent.group) && (attachment.parent.group.officers_of_self_and_ancestors.include?(user)) &&
        ((attachment.author == user) || (attachment.parent.author == user))
      end
      can :destroy, Attachment do |attachment|
        can? :update, attachment
      end
    end
  end
  
  # ===============================================================================================
  # Bundesämter sind im Moment mit dem Flag :global_officer versehen.
  # Bundesamtsträger dürfen insbesondere:
  #
  #   - Beliebige Mitglieder-Listen exportieren
  #   - Nachrichten an beliebige Gruppen schicken
  #
  def rights_for_global_officers
    super
  end
  
  # ===============================================================================================
  def rights_for_everyone
    #
    # Inherited from your_platform:
    # - read imprint
    # - listing public events
    # - ics calendar feed
    #
    super
    
    # Nobody, not even global admins, can send posts to deceased-groups.
    # Also creating events for those groups is not good.
    # 
    cannot [:create_post_for, :create_event], Group do |group|
      group.name.include? "Verstorbene"
    end
  end
  
end

class Ability
  prepend AbilityDefinitions
end
