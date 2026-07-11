#
# This module contains the methods of the Group model regarding the associated
# user group memberships and users, i.e. members.
#
concern :GroupMemberships do

  included do

    # User Group Memberships
    # ==========================================================================================

    # All memberships of the group: the direct memberships in the group
    # itself and in the groups of its subtree. There is no stored row
    # per (group, user) pair anymore -- a user with two direct
    # memberships in the subtree appears with two rows here.
    #
    def memberships
      Membership.direct.where(ancestor_id: [id] + descendant_group_ids)
    end

    # This associates all memberships of the group that are direct, i.e. direct
    # parent_group-child_user memberships.
    #
    has_many :direct_memberships, -> { where ancestor_type: 'Group', descendant_type: 'User', direct: true },
        foreign_key: :ancestor_id, class_name: "Membership"

    # The materialized indirect membership rows (direct: false). Only
    # the closure maintenance still touches them; do not read from
    # them. They disappear with
    # https://github.com/fiedl/wingolfsplattform/issues/129
    #
    has_many :indirect_memberships, -> { where ancestor_type: 'Group', descendant_type: 'User', direct: false },
        foreign_key: :ancestor_id, class_name: "Membership"


    #  This method builds a new membership having this group (self) as group associated.
    #
    def build_membership
      direct_memberships.build(descendant_type: 'User')
    end

    # All direct memberships in this group and its subtree of sub groups,
    # for example for the membership management view of a corporation.
    #
    # Memberships in descendant officer groups are excluded, matching the
    # former neo4j query: officers appear on the member list of their own
    # officer group, but not on the list of the group they are officers of.
    #
    def descendant_memberships
      subtree_group_ids = DagLink.descendant_ids_through_same_type 'Group', [id]
      regular_group_ids = Group.where(id: subtree_group_ids)
        .where("type IS NULL OR type != 'OfficerGroup'").pluck(:id)
      Membership.direct.where(ancestor_id: [id] + regular_group_ids)
    end

    # This returns the Membership object that represents the membership of the
    # given user in this group: the direct membership if there is one,
    # otherwise the derived, read-only indirect membership.
    #
    # options:
    #   - also_in_the_past
    #
    def membership_of(user, options = {})
      if options[:also_in_the_past]
        base = Membership.with_invalid
      else
        base = Membership
      end
      base.find_by_user_and_group(user, self) || derived_indirect_membership_of(user, options)
    end

    def derived_indirect_membership_of(user, options = {})
      membership = IndirectMembership.new(self, user)
      return nil unless membership.present?
      return nil unless options[:also_in_the_past] || membership.currently_valid?
      membership
    end

    # This returns a string of the titles of the direct members of this group. This is used
    # for in-place editing, for example.
    #
    # The string would be something like this:
    #
    #    "#{user1.title}, #{user2.title}, ..."
    #
    def direct_members_titles_string
      direct_members.collect { |user| user.title }.join( ", " )
    end

    # This sets the memberships of a group according to the given string of user titles.
    #
    # For example, after calling
    #
    #    direct_members_titles_string = "#{user1.title}, #{user2.title}",
    #
    # the users `user1` and `user2` are the only direct members of the group.
    # The memberships are removed using the standard methods, which means that the memberships
    # are only marked as deleted. See: acts_as_paranoid_dag gem.
    #
    def direct_members_titles_string=(titles_string)
      new_members_titles = titles_string.to_s.split(",")
      new_members = new_members_titles.collect do |title|
        u = User.find_by_title( title.strip )
        self.errors.add :direct_member_titles_string, 'user not found: #{title}' unless u
        u
      end
      self.members = new_members
    end

    def members=(new_members)
      for member in self.direct_members
        unassign_user member unless member.in? new_members if member
      end
      for new_member in new_members
        assign_user new_member if new_member
      end
      self.touch
    end


    # User Assignment
    # ==========================================================================================

    # This assings the given user as a member to the group, i.e. this will
    # create a Membership.
    #
    # If a membership already exists, it will be extended.
    #
    def assign_user(user, options = {})
      raise RuntimeError, "no user given" if not user
      time_of_joining = options[:joined_at] || options[:at] || options[:time] || Time.zone.now
      if m = Membership.with_past.find_by_user_and_group(user, self)
        m.valid_from = time_of_joining if m.valid_from && time_of_joining < m.valid_from
        m.valid_to = nil
        m.save
        m
      else
        m = Membership.create descendant_id: user.id, ancestor_id: self.id
        m.update_attributes valid_from: time_of_joining # It does not work when added in `create`.
        m
      end
    end

    # This method will remove a Membership, i.e. terminate the membership
    # of the given user in this group.
    #
    def unassign_user( user, options = {} )
      if user and membership = Membership.find_by(user: user, group: self)
        time_of_unassignment = options[:at] || options[:time] || Time.zone.now
        membership.invalidate(at: time_of_unassignment)
      end
    end


    def calculate_validity_range_of_indirect_memberships
      self.indirect_memberships.where(valid_from: nil).each do |membership|
        membership.recalculate_validity_range_from_direct_memberships
        membership.save
      end
    end


    # Members
    # ==========================================================================================

    # The group members (users), direct ones as well as the users of
    # the subtree groups.
    #
    def members
      Dag::MembersProxy.new group: self, members: User.where(id: memberships.select(:descendant_id))
    end

    def member_ids
      members.pluck(:id)
    end

    # Member counts
    # ==========================================================================================
    # These follow the former materialized pair rows: one membership
    # per (group, user) counted from first joining to last leaving,
    # even though a user can have several direct memberships in the
    # subtree.

    def member_count(at: Time.zone.now)
      memberships.at_time(at).distinct.count(:descendant_id)
    end

    def new_member_ids(during:)
      memberships.with_past.group(:descendant_id).minimum(:valid_from)
        .select { |_, joined_at| joined_at && during.cover?(joined_at) }.keys
    end

    def new_member_count(during:)
      new_member_ids(during: during).count
    end

    def ended_membership_count(during:)
      open_user_ids = memberships.with_past.where(valid_to: nil).pluck(:descendant_id)
      memberships.with_past.group(:descendant_id).maximum(:valid_to)
        .count { |user_id, left_at| left_at && during.cover?(left_at) && !user_id.in?(open_user_ids) }
    end

    # This associates only the direct group members (users).
    #
    has_many(:direct_members,
      -> { where('dag_links.ancestor_type' => 'Group', 'dag_links.direct' => true).distinct },
      through: :direct_memberships,
      source: :descendant, source_type: 'User'
      )

    # Only the members by subtree membership, without the direct ones.
    #
    def indirect_members
      members.where.not(id: direct_memberships.select(:descendant_id))
    end

  end
end
