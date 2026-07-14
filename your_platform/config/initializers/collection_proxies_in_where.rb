# Lets the dag collection proxies (group.members, user.groups, ...)
# render as subqueries when passed to where(...), e.g.
#
#     Post.where(group_id: user.groups)
#
# Until rails 6.0 this went through the documented
# PredicateBuilder.register_handler extension point; 6.1 removed it
# (the handler dispatch is hard-coded now), so the proxies unwrap to
# their relation before the builder dispatches — the rails-own
# Relation branch then takes over, bind parameters included.
# https://github.com/fiedl/wingolfsplattform/issues/129
#
module DagCollectionProxiesInWhere
  def build(attribute, value, *args)
    value = value.__getobj__ if value.is_a?(::Dag::CollectionProxy)
    super(attribute, value, *args)
  end
end

ActiveRecord::PredicateBuilder.prepend DagCollectionProxiesInWhere
