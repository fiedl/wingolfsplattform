concern :Structureable do

  included do
    before_destroy :destroy_links

    include Flags
    include SpecialGroups
    include StructureableRoles
  end

  def parent
    parents.first
  end

  # When a dag node is destroyed, also destroy the corresponding dag links.
  # Otherwise, there would remain ghost dag links in the database.
  #
  def destroy_dag_links
    (self.links_as_parent + self.links_as_child).each(&:destroy)
  end

  # This somehow identifies which are the ancestors of this structureable.
  # For example, this is used in the breadcrumb helper.
  #
  def ancestors_cache_key
    "Group#{ancestor_group_ids if respond_to?(:ancestor_group_ids)}Page#{ancestor_page_ids if respond_to?(:ancestor_page_ids)}User#{ancestor_user_ids if respond_to?(:ancestor_user_ids)}"
  end
  def children_cache_key
    "Group#{child_group_ids.sum if respond_to?(:child_group_ids)}Page#{child_page_ids.sum if respond_to?(:child_page_ids)}User#{child_user_ids.sum if respond_to?(:child_user_ids)}"
  end

  def destroy_links
    self.destroy_dag_links
  end

  # Move the node to another parent.
  #
  def move_to(parent_node)
    raise RuntimeError, 'Case not handled, yet. This node has several parents. Not moving.' if self.parents.count > 1
    if parent_node != self.parents.first
      old_updated_at = self.updated_at
      self.links_as_child.destroy_all
      parent_node << self
      self.update_attribute :updated_at, old_updated_at
    end
  end

  # Adding child objects.
  #
  def <<(object)
    begin
      if object.kind_of? User
        raise RuntimeError 'Users can only be assigned to groups.' unless self.kind_of? Group
        self.assign_user(object) unless self.child_users.include? object
      elsif object.kind_of? Group
        # A new edge next to an existing indirect path is just a
        # second edge; there is no materialized link to promote.
        object.parent_groups << self unless self.child_groups.reload.include? object
      elsif object.kind_of? Page
        self.child_pages << object unless self.child_pages.include? object
      elsif object.kind_of? Event
        unless self.events.include? object
          self.events << object
        end
      elsif object.kind_of? Project
        self.child_projects << object unless self.child_projects.include? object
      elsif object.kind_of? WorkflowKit::Workflow
        # # This does not work since `child_workflows` is no real association:
        # self.child_workflows << object unless self.child_workflows.include? object
        object.parent_groups << self unless object.parent_groups.include? self
      elsif object.nil?
        raise RuntimeError, "Something is wrong! You've tried to add nil."
      else
        raise RuntimeError, "Case not handled yet. Please implement this. It's easy :)"
      end
    rescue ActiveRecord::RecordInvalid => e
      logger.warn(e.message)
      logger.warn("ancestor: " + self.inspect)
      logger.warn("descendant: " + object.inspect)
      logger.warn("record: " + e.record.errors.inspect)
      logger.warn(e.record)
      print "WARN #{e.message}\n".red
      print "ancestor: #{self.inspect}\n".red
      print "descendant: #{object.inspect}\n".red
      print "record: #{e.record.errors.inspect}\n".red
      print "#{e.record.inspect}\n".red
      raise e if not File.basename($0) == 'rake'
    end
  end

end
