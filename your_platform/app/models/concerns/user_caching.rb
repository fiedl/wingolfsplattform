concern :UserCaching do

  # Please make sure this concern is included at the bottom
  # of the class. Otherwiese, the methods referred to here
  # are not defined, yet.
  #
  included do
    after_save { RenewCacheJob.perform_later(records: self, time: Time.zone.now) }

    # Only methods whose recomputation costs clearly more than a cache
    # round trip are cached: multi-query aggregations and graph
    # traversals. Single profile-field or flag lookups (email, dates,
    # gender, hidden) are one indexed query each -- caching them saves
    # nothing per read but costs an invalidation and a renewal job on
    # every write, forever.
    cache :name_with_surrounding
    cache :address_label
    cache :current_corporations
    cache :sorted_current_corporations
    cache :my_groups_in_first_corporation
    cache :status_group_in_primary_corporation
    cache :status_export_string
    cache :workflows_by_corporation

    cache :group_ids_by_category

    # UserRoles
    cache :admin_of_anything?
    cache :former_member?
    cache :developer?
    cache :beta_tester?
    cache :global_admin?
    cache :global_officer?

    # ProfileFields
    cache :address_fields_json
  end

  # # Aparently, the `StructureableMixins::Roles` don't work correctly
  # # for users, yet. Thus, it's harmful to try to cache those methods,
  # # because they create lots of errors on `fill_cache`.
  # #
  # # TODO: Fix `StructureableMixins::Roles` before including the
  # # `StructureableRoleCaching`.
  # #
  # include StructureableRoleCaching
end