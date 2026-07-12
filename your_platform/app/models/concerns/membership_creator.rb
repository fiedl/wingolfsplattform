concern :MembershipCreator do

  class_methods do

    # Created through DagLink and re-typed by DagLinkTypes: the
    # returned object is a Membership regardless of the called class,
    # so Memberships::Status callbacks (gap correction) only run on
    # records that were loaded as such -- as before.
    def create(attributes = {})
      attributes[:ancestor_id] ||= attributes[:group_id] || attributes[:group].try(:id)
      attributes[:descendant_id] ||= attributes[:user_id] || attributes[:user].try(:id)
      attributes[:ancestor_type] = "Group"
      attributes[:descendant_type] = "User"
      attributes = attributes.except(:group_id, :user_id, :user, :group)
      membership = DagLink.create(attributes).becomes(Membership)

      membership.valid_from ||= Time.zone.now
      membership.save

      membership
    end

  end

end
