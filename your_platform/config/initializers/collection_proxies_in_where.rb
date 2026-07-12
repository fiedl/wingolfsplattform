# Lets the dag collection proxies (group.members, user.groups, ...)
# render as subqueries when passed to where(...), e.g.
#
#     Post.where(group_id: user.groups)
#
# This uses the handler rails itself uses for relations, through the
# documented PredicateBuilder.register_handler extension point.
#
# Note for the rails 6 upgrade: register_handler was removed in 6.0,
# where the handler dispatch became a hard-coded case statement. This
# hook then needs a new home -- one contained decision, documented in
# https://github.com/fiedl/wingolfsplattform/issues/129.
#
module DagCollectionProxiesInWhere
  def initialize(table)
    super
    register_handler ::Dag::CollectionProxy,
      ActiveRecord::PredicateBuilder::RelationHandler.new
  end

  # The handler above covers the query construction, but rails
  # collects the bind parameters of subquery values separately, with a
  # hard-coded `when Relation` -- which a proxy does not match. The
  # proxies unwrap to their relation here so their bind parameters
  # travel along.
  def create_binds_for_hash(attributes)
    attributes = attributes.transform_values { |value|
      value.is_a?(::Dag::CollectionProxy) ? value.__getobj__ : value
    }
    super
  end
end

ActiveRecord::PredicateBuilder.prepend DagCollectionProxiesInWhere
