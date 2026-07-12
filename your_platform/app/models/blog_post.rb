class BlogPost < Page
  include Commentable

  include HostAndGuestGroups

  def self.relevant_to(user)
    group_ids_the_user_is_no_member_of = Group.pluck(:id) - user.group_ids
    pages_of_those_groups = Dag::Traversal.descendants ancestor_type: 'Group',
      descendant_type: 'Page', ancestor_ids: group_ids_the_user_is_no_member_of
    return where.not(id: pages_of_those_groups)
  end

  def as_json(*args)
    super.merge({
      youtube: teaser_youtube_url
    })
  end

end
