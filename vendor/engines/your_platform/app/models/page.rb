class Page < ActiveRecord::Base

  attr_accessible        :content, :title, :redirect_to

  is_structureable       ancestor_class_names: %w(Page User Group), descendant_class_names: %w(Page User Group)
  is_navable

  has_many :attachments, as: :parent, dependent: :destroy

  belongs_to :author, :class_name => "User", foreign_key: 'author_user_id'
  
  def delete_cache
    Structureable
    delete_cache_structureable
  end

  # Url
  # ----------------------------------------------------------------------------------------------------

  # This sets the format of the Page urls to be
  # 
  #     example.com/pages/24-products
  #
  # rather than just
  #
  #     example.com/pages/24
  #
  def to_param
    "#{id} #{title}".parameterize
  end
  
  
  # Quick Assignment of Children
  # ----------------------------------------------------------------------------------------------------

  # Add a child to this page. This could be a blog entry or another page or even a group.
  # Example:
  # 
  #     my_page << another_page
  #
  def <<(child)
    unless child.in? self.children
      if child.in? self.descendants(true)
        link = DagLink.where(
          ancestor_type: 'Page', ancestor_id: self.id, 
          descendant_type: child.class.name, descendant_id: child.id
        ).first
        link.make_direct
        link.save
      else
        self.child_pages << child if child.kind_of? Page
        self.child_groups << child if child.kind_of? Group
      end
    end
  end


  # Redirection
  # ----------------------------------------------------------------------------------------------------

  def redirect_to

    # http://example.com
    return super if super.kind_of?(String) && super.include?("://")

    # users#index
    if super.kind_of?(String) && super.include?("#")
      controller, action = super.split("#")
      return { controller: controller, action: action } if controller && action
    end

    # { controller: "users", action: "index" }
    return super if super.kind_of? Hash

    # else
    return nil
  end



  # Association Related Methods
  # ----------------------------------------------------------------------------------------------------

  # This return alls attachments of a certain type.
  # +type+ could be something like `image` or `pdf`. It will be compared to the attachments' mime type.
  #
  def attachments_by_type( type )
    attachments.find_by_type type
  end


  # Blog Entries
  # ----------------------------------------------------------------------------------------------------

  # This method returns all Page objects that can be regarded as blog entries of self.
  # Blog entries are simply child pages of self that have the :blog_entry flag.
  # They won't show up in the vertical menu.
  #
  # Page: "My Blog"
  #   |------------------ Page: "Entry 1"
  #   |------------------ Page: "Entry 2"
  #
  def blog_entries
    self.child_pages.where(type: "BlogPost").order('created_at DESC')
  end


  # Finder and Creator Methods
  # ----------------------------------------------------------------------------------------------------


  # root

  def self.find_root
    Page.find_by_flag( :root )
  end

  def self.find_or_create_root
    self.find_root || self.create_root
  end

  def self.create_root
    root_page = Page.create(title: "Root")
    root_page.add_flag :root
    n = root_page.nav_node; n.slim_menu = true; n.save; n = nil
    return root_page
  end


  # intranet root

  def self.find_intranet_root
    Page.find_by_flag( :intranet_root )
  end

  def self.find_or_create_intranet_root
    self.find_intranet_root || self.create_intranet_root
  end

  def self.create_intranet_root
    root_page = Page.find_by_flag :root
    root_page = self.create_root unless root_page
    intranet_root = root_page.child_pages.create(title: "Intranet")
    intranet_root.add_flag :intranet_root
    return intranet_root
  end

  def self.intranet_root
    self.find_or_create_intranet_root
  end


  # help page

  def self.find_help_page
    Page.find_by_flag( :help )
  end

  def self.find_or_create_help_page
    self.find_help_page || self.create_help_page
  end

  def self.create_help_page
    help_page = Page.create(title: "Help")
    help_page.add_flag :help
    n = help_page.nav_node; n.hidden_menu = true; n.save;
    return help_page
  end

end
