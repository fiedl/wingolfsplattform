class HorizontalNav
  def initialize(args)
    @user = args[:user]
    @current_navable = args[:current_navable]
  end
  
  def self.for_user(user, args = {})
    self.new(args.merge({ user: user }))
  end
  
  def link_objects 
    objects = navables
    objects << { title: I18n.t(:sign_in), :controller => :sessions, :action => :new } if not logged_in?
    objects
  end
  
  def navables
    [ Page.find_intranet_root ] + (@user.try(:cached_current_corporations).try(:collect) { |corporation| corporation.becomes(Group) } || [])
  end
  
  def currently_in_intranet?
    current_navable.ancestor_pages.include? Page.find_intranet_root
  end
  
  def current_navable
    @current_navable
  end
  
  def logged_in?
    return true if @user
  end

  def categories_the_current_navable_falls_in
    if current_navable
      navables.select do |navable|
        ( current_navable.ancestors + [ current_navable ] ).include? navable
      end
    end
  end

  def most_special_category
    categories_the_current_navable_falls_in.try(:select) do |navable|
      (navable.descendants & categories_the_current_navable_falls_in).empty?
    end.try(:first)
  end

  def cached_most_special_category
    Rails.cache.fetch( [@user, "most_special_category"] ) do
      most_special_category
    end  
  end
end
