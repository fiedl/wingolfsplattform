# Base class of the dag collection proxies (group.members, user.groups,
# page.guests, ...): reading enumerates the wrapped relation, writing
# goes through the membership methods of the subclasses.
#
# Passed to where(...), a proxy renders as a subquery like a relation
# would -- see config/initializers/collection_proxies_in_where.rb.
#
class Dag::CollectionProxy < SimpleDelegator

  # The bulk operations of the wrapped relation would act on the
  # target table itself -- deleting users or groups, not memberships.
  # Nobody wants that to happen by accident.
  def delete_all(*)
    raise NotImplementedError, "Bulk operations are not available on #{self.class.name}; " +
      "operate on the memberships instead."
  end

  def destroy_all(*)
    raise NotImplementedError, "Bulk operations are not available on #{self.class.name}; " +
      "operate on the memberships instead."
  end

  def update_all(*)
    raise NotImplementedError, "Bulk operations are not available on #{self.class.name}; " +
      "operate on the memberships instead."
  end

  def ==(other)
    return false if other.nil?
    to_a == (other.respond_to?(:to_a) ? other.to_a : other)
  end

end
