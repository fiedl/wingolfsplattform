module ProfileFields

  # Email List Contact Information
  #
  class MailingListEmail < Email
    def self.model_name; ProfileField.model_name; end

    # The people on this mailing list are the members of the group
    # this email address belongs to.
    #
    # This cannot be a `has_many through:` association anymore:
    # `Group#memberships` is a regular method since the memberships
    # of a group are derived from the direct memberships of its
    # descendant groups rather than stored as rows of their own.
    #
    def memberships
      group.memberships
    end
  end

end
