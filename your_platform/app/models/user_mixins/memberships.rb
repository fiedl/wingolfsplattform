# Just to auto-load this class for sti.
Memberships::Status

#
# This module contains the methods of the User model regarding the associated
# user group memberships and groups.
#
module UserMixins::Memberships

  extend ActiveSupport::Concern

  included do

    # User Group Memberships
    # ==========================================================================================

    # The user's memberships. Only direct memberships are stored;
    # memberships in ancestor groups derive from them at read time
    # (IndirectMembership).
    #
    has_many :memberships, -> { where ancestor_type: 'Group', descendant_type: 'User', direct: true },
         foreign_key: :descendant_id

    # This associates all memberships of the group that are direct, i.e. direct
    # parent_group-child_user memberships.
    #
    has_many :direct_memberships, -> { where ancestor_type: 'Group', descendant_type: 'User', direct: true },
         foreign_key: :descendant_id, class_name: "Membership"

    # The materialized indirect membership rows (direct: false). Only
    # the closure maintenance still touches them; do not read from
    # them. They disappear with
    # https://github.com/fiedl/wingolfsplattform/issues/129
    #
    has_many :indirect_memberships, -> { where ancestor_type: 'Group', descendant_type: 'User', direct: false },
        foreign_key: :descendant_id, class_name: "Membership"


    # This returns the membership of the user in the given group if
    # existant: the direct membership or the derived indirect one.
    #
    def membership_in( group )
      group.membership_of self
    end


    # Groups the user is member of
    # ==========================================================================================

    # The groups the user is member of: the groups of his valid direct
    # memberships and all groups above them.
    #
    def groups
      direct_group_ids = direct_memberships.pluck(:ancestor_id)
      Dag::MemberGroups.new self, Group.where(id: direct_group_ids +
        Dag::Query.ids_from(start_type: 'Group', start_ids: direct_group_ids,
          direction: :ancestor, target_type: 'Group'))
    end

    def group_ids
      groups.pluck(:id)
    end

    # This associates only the direct groups.
    #
    has_many(:direct_groups,
      -> { where('dag_links.descendant_type' => 'User', 'dag_links.direct' => true).distinct },
      through: :direct_memberships,
      source: :ancestor, source_type: 'Group'
      )

    # Only the groups the user is member of by subtree membership,
    # i.e. without his direct groups.
    #
    def indirect_groups
      groups.where.not(id: direct_memberships.select(:ancestor_id))
    end

  end

  def joined_at(group)
    begin
      group.membership_of(self).try(:valid_from)
    rescue ArgumentError => e
      membership = group.membership_of(self)
      Issue.scan membership if membership
      return membership.try(:valid_from)
    end
  end

  def date_of_joining(group)
    self.joined_at(group).try(:to_date)
  end
end

# In order to have auto-loading of sti classes work correctly,
# we need to require the descendant classes of `Membership` here.
# Otherwise, calls like `Membership.all` won't include instances
# of the subclasses like `Memberships::Status` if they haven't
# been used previously.
#
# This has caused a serious bug previously, which is discussed in:
# https://trello.com/c/VvY1q6Cs/1127-strange-validity-ranges
#
# See also:
#
# - http://guides.rubyonrails.org/autoloading_and_reloading_constants.html#autoloading-and-sti
# - http://stackoverflow.com/q/3245838/2066546
# - http://stackoverflow.com/q/18506933/2066546
#
require 'memberships/status'
