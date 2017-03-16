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
    can :index, PublicActivity::Activity
    can :index, Issue

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

      # Administratoren einer Aktivitas dürfen ihr Amt weitergeben.
      # Siehe: https://trello.com/c/SSciMMfB/1101-aktiven-admins-durfen-ihr-amt-weitergeben
      # Und: http://support.wingolfsplattform.org/tickets/1530#reply-3682
      #
      # Damit Fehleingaben korrigiert werden können sei es einem scheidenden Admin
      # bis zu fünf Minuten, nachdem er das Amt abgegeben hat, noch möglich,
      # den Admin zu ändern.
      #
      # Da für einen gewesenen Admin die Methode `rights_for_local_admins` nicht mehr
      # aufgerufen wird, ist dies unter `rights_for_signed_in_users` definiert.

      can :create_memberships, Group do |group|
        can? :update, group
      end
      can :create_officer_group_for, Group do |group|
        can? :update, group
      end
      can :export_stammdaten_for, Group do |group|
        can? :update, group
      end

      can :destroy, Group do |group|
        group.admins_of_self_and_ancestors.include?(user) and

        # One can't destroy a group with members.
        group.descendant_users.count == 0 and

        # The group must have no flags. Otherwise, it's used by the system.
        group.flags.count == 0
      end

      can [:update, :change_first_name, :change_alias, :change_status, :create_account_for], User, id: Role.of(user).administrated_users.map(&:id)
      can :manage, UserAccount, user_id: Role.of(user).administrated_users.map(&:id)
      can :update_members, Group do |group|
        can? :update, group
      end

      can :execute, Workflow do |workflow|
        # Local admins can execute workflows of groups they're admins of.
        # And they can execute the mark_as_deceased workflow, which is a global workflow.
        #
        (workflow == Workflow.find_mark_as_deceased_workflow) or
        (workflow.admins_of_ancestors.include?(user))
      end

      can :manage, Page do |page|
        page.admins_of_self_and_ancestors.include? user
      end
      can :manage, Attachment do |attachment|
        can? :manage, attachment.parent
      end

      can :manage, ProfileField do |profile_field|
        profile_field.profileable.nil? ||  # in order to create profile fields
          (can?(:update, profile_field.profileable) && profile_field.key != "W-Nummer")
      end
      can :manage, UserGroupMembership do |membership|
        can? :update, membership.user
      end

      # Lokale Administratoren dürfen Aktivmeldungen eintragen, wenn sie mindestens
      # eine Aktivitas administrieren.
      #
      can :create, User do
        user.administrated_aktivitates.count > 0
      end

      # Lokale Administratoren dürfen Semesterprogramme löschen.
      #
      # Da dies nur dazu dient, versehentlich erstellte Programme zu löschen,
      # nur, solange noch kein PDF hochgeladen wurde. Die Termine selbst gehen
      # nicht verloren, da diese nicht mit gelöscht werden, sondern separat
      # in der Datenbank bleibne. -> Siehe `rights_for_everyone`
      #
      can :destroy, SemesterCalendar do |semester_calendar|
        can?(:update, semester_calendar.group)
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

    # Any logged-in user can view, who are the admins.
    #
    can :index, :admins

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
      not ((parent_field.type == 'ProfileFields::BankAccount') &&
        parent_field.profileable.kind_of?(User) && (parent_field.profileable.id != user.id))
    end

    can :update, ProfileField do |profile_field|
      (profile_field.profileable == user) and (profile_field.key.in? ['klammerung'])
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

    # Administratoren einer Aktivitas dürfen ihr Amt weitergeben.
    # Siehe: https://trello.com/c/SSciMMfB/1101-aktiven-admins-durfen-ihr-amt-weitergeben
    # Und: http://support.wingolfsplattform.org/tickets/1530#reply-3682
    #
    # Damit Fehleingaben korrigiert werden können sei es einem scheidenden Admin
    # bis zu fünf Minuten, nachdem er das Amt abgegeben hat, noch möglich,
    # den Admin zu ändern.
    #
    # Da für einen gewesenen Admin die Methode `rights_for_local_admins` nicht mehr
    # aufgerufen wird, ist dies unter `rights_for_signed_in_users` definiert.
    #
    can :update_memberships, OfficerGroup do |group|
      (group.members.include?(user) || group.memberships.at_time(5.minutes.ago).map(&:user_id).include?(user.id)) &&
        group.has_flag?(:admins_parent) && group.scope.kind_of?(Aktivitas)
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
    # - edit their pages if they are page officer
    # - create and destroy pages and attachments
    #
    super

    if not read_only_mode?

      # Amtsträger der Aktivitas dürfen Semesterprogramme für die Verbindung erstellen.
      can :create, SemesterCalendar
      can :create_semester_calendar_for, Corporation do |corporation|
        user.corporations_the_user_is_officer_in.include? corporation
      end
      can :update, SemesterCalendar do |semester_calendar|
        can? :create_semester_calendar_for, semester_calendar.group
      end
      can :destroy, SemesterCalendar do |semester_calendar|
        can? :update, semester_calendar
      end
      can [:create_event, :create_event_for], Corporation do |corporation|
        can? :create_semester_calendar_for, corporation
      end
      can [:update, :destroy, :invite_to], Event do |event|
        event.group.try(:corporation) && user.corporations_the_user_is_officer_in.include?(event.group.corporation)
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

    can :export, :wingolfsblaetter_export_format
    can :index, :wingolfsblaetter_dashboard
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

    # Feature Switches
    cannot :create_comment_for, BlogPost

    # Jeder Internetbenutzer kann Semesterprogramm-PDFs herunterladen, damit
    # die Verbindungen die Möglichkeit haben, die PDFs zu verlinken.
    #
    can [:read, :download], Attachment do |attachment|
      attachment.parent_type == "SemesterCalendar"
    end

    # Nobody, not even global admins, can send posts to deceased-groups.
    # Also creating events for those groups is not good.
    #
    cannot [:create_post_for, :create_post, :create_event_for, :create_event], Group do |group|
      group.name.try(:include?, "Verstorbene")
    end
  end

  def rights_for_beta_testers
    super
  end

  def rights_for_developers
    super

    can :use, :site_links
  end

end

class Ability
  prepend AbilityDefinitions
end
