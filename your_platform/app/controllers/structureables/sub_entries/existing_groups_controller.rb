class Structureables::SubEntries::ExistingGroupsController < Structureables::SubEntriesController

    expose :group

    def create
      authorize! :create_group_for, parent

      parent << group
      parent.delete_cached :nav_child_group_ids if Group.use_caching?
      parent.delete_cache if Group.use_caching?

      redirect_to parent
    end

end