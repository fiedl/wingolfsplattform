# Recursive CTE queries over the direct dag links.
#
# These answer the transitive questions that the materialized closure
# rows (direct: false) answer today, reading only the direct edges:
# https://github.com/fiedl/wingolfsplattform/issues/129
#
class Dag::Query

  # SQL subselect for the ids of all nodes of `target_type` reachable
  # from the start nodes in the given direction (:descendant or
  # :ancestor), for embedding in `WHERE id IN (...)`.
  #
  # The type strings are the ones stored in the polymorphic columns,
  # i.e. `base_class.name` ('WorkflowKit::Workflow', not 'Workflow').
  #
  # UNION deduplicates and thereby terminates on diamonds and cycles.
  # Link validity is deliberately not filtered here: like the closure
  # rows, the structural walk includes expired links. Validity scopes
  # live in the Membership layer.
  #
  def self.sql(start_type:, start_ids:, direction:, target_type:)
    from, to = case direction
      when :descendant then ['ancestor', 'descendant']
      when :ancestor then ['descendant', 'ancestor']
      else raise ArgumentError, "direction must be :descendant or :ancestor"
    end
    if start_ids == :all
      id_condition = ""
    else
      ids = start_ids.collect { |id| Integer(id) }
      return "SELECT 1 WHERE FALSE" if ids.empty?
      id_condition = "AND l.#{from}_id IN (#{ids.join(', ')})"
    end
    <<~SQL
      WITH RECURSIVE walk(node_type, node_id) AS (
          SELECT l.#{to}_type, l.#{to}_id
            FROM dag_links l
           WHERE l.direct = TRUE
             AND l.#{from}_type = #{connection.quote(start_type)}
             #{id_condition}
        UNION
          SELECT l.#{to}_type, l.#{to}_id
            FROM dag_links l
            JOIN walk w ON l.#{from}_type = w.node_type AND l.#{from}_id = w.node_id
           WHERE l.direct = TRUE
      )
      SELECT node_id FROM walk WHERE node_type = #{connection.quote(target_type)}
    SQL
  end

  # Like .ids, but for callers that have raw type names and ids at hand
  # instead of records. start_ids may be :all to walk from every node
  # of the start type.
  #
  def self.ids_from(start_type:, start_ids:, direction:, target_type:)
    connection.select_values(sql(
      start_type: start_type, start_ids: start_ids,
      direction: direction, target_type: target_type
    )).collect(&:to_i)
  end

  # Ids of all nodes of the given class reachable from the node (or
  # array of same-class nodes), e.g.
  #
  #     Dag::Query.ids(group, direction: :descendant, type: 'User')
  #
  def self.ids(node_or_nodes, direction:, type:)
    nodes = Array(node_or_nodes)
    return [] if nodes.empty?
    connection.select_values(sql(
      start_type: nodes.first.class.base_class.name,
      start_ids: nodes.collect(&:id),
      direction: direction,
      target_type: type.to_s.constantize.base_class.name
    )).collect(&:to_i)
  end

  # Over which time ranges is the user a member of the group, directly
  # or through any path of subgroups?
  #
  # Validity intersects along each path -- the user is only a member of
  # the corporation through a status group while the user belongs to
  # the status group *and* the status group belongs to the corporation.
  # The per-path ranges union into episodes; gaps stay visible: leaving
  # in 2010 and rejoining in 2015 gives two episodes, unlike the
  # min/max envelope of the materialized indirect memberships.
  #
  # Returns an array of [from, to] time pairs, nil meaning unbounded.
  #
  def self.membership_episodes(group, user)
    rows = connection.select_rows(<<~SQL)
      WITH RECURSIVE walk(node_type, node_id, acc) AS (
          SELECT l.descendant_type, l.descendant_id, #{link_validity}
            FROM dag_links l
           WHERE l.direct = TRUE
             AND l.ancestor_type = 'Group' AND l.ancestor_id = #{Integer(group.id)}
             AND NOT isempty(#{link_validity})
        UNION ALL
          SELECT l.descendant_type, l.descendant_id, w.acc * #{link_validity}
            FROM dag_links l
            JOIN walk w ON l.ancestor_type = w.node_type AND l.ancestor_id = w.node_id
           WHERE l.direct = TRUE
             AND NOT isempty(w.acc * #{link_validity})
      ) CYCLE node_type, node_id SET is_cycle USING cycle_path
      SELECT lower(episode), upper(episode)
        FROM unnest((
          SELECT range_agg(acc)
            FROM walk
           WHERE node_type = 'User' AND node_id = #{Integer(user.id)}
             AND NOT is_cycle
        )) AS episode
       ORDER BY 1
    SQL
    rows.collect { |from, to| [parse_bound(from), parse_bound(to)] }
  end

  # Structural links carry no validity dates; NULL means unbounded.
  # Corrupted rows with valid_from > valid_to exist in production and
  # would make tstzrange raise; they count as never valid.
  def self.link_validity
    "(CASE WHEN l.valid_from IS NOT NULL AND l.valid_to IS NOT NULL AND l.valid_from > l.valid_to" +
    " THEN 'empty'::tstzrange" +
    " ELSE tstzrange(coalesce(l.valid_from, '-infinity'), coalesce(l.valid_to, 'infinity'), '[)') END)"
  end

  # The adapter returns range bounds as Time, or as infinite Float or
  # String for the unbounded ends.
  def self.parse_bound(value)
    case value
    when nil, Float then nil
    when String then value.include?('infinity') ? nil : Time.zone.parse(value)
    else value.in_time_zone
    end
  end

  def self.connection
    ActiveRecord::Base.connection
  end

end
