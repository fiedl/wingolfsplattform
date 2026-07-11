class BlogPost < Page
  include Commentable

  include HostAndGuestGroups

  def self.relevant_to(user)
    group_ids_the_user_is_no_member_of = Group.pluck(:id) - user.group_ids
    page_ids_of_those_groups = Dag::Query.ids_from start_type: 'Group',
      start_ids: group_ids_the_user_is_no_member_of, direction: :descendant, target_type: 'Page'
    return where.not(id: (page_ids_of_those_groups + [0])) # +[0]-hack: otherwise the list is empty when all pages should be shown, i.e. for fresh systems.
  end

  def as_json(*args)
    super.merge({
      youtube: teaser_youtube_url
    })
  end

end
