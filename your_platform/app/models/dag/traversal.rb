# Answers the transitive questions of the dag by walking the direct
# links with recursive SQL queries -- which nodes lie above or below a
# node, and over which time ranges a membership holds along the way.
# https://github.com/fiedl/wingolfsplattform/issues/129
#
class Dag::Traversal

  # Ids of all nodes of the given class reachable below the node (or
  # array of same-class nodes), e.g.
  #
  #     Dag::Traversal.descendant_ids_of(group, type: 'User')
  #
  def self.descendant_ids_of(node_or_nodes, type:)
    reachable_ids_of node_or_nodes, direction: :descendant, type: type
  end

  # Ids of all nodes of the given class reachable above the node or
  # array of same-class nodes.
  #
  def self.ancestor_ids_of(node_or_nodes, type:)
    reachable_ids_of node_or_nodes, direction: :ancestor, type: type
  end

  # Like descendant_ids_of, for callers that have raw type names and
  # ids at hand instead of records. of_ids may be :all to start from
  # every node of the start type.
  #
  #     Dag::Traversal.descendant_ids(of_type: 'Group', of_ids: [1, 2], type: 'Page')
  #
  def self.descendant_ids(of_type:, of_ids:, type:)
    connection.select_values(descendant_ids_sql(of_type: of_type, of_ids: of_ids, type: type)).collect(&:to_i)
  end

  def self.ancestor_ids(of_type:, of_ids:, type:)
    connection.select_values(ancestor_ids_sql(of_type: of_type, of_ids: of_ids, type: type)).collect(&:to_i)
  end

  # SQL subselect for the descendant ids, for embedding in a
  # `WHERE id IN (...)` clause. The type strings are the ones stored in
  # the polymorphic columns, i.e. `base_class.name`
  # ('WorkflowKit::Workflow', not 'Workflow').
  #
  def self.descendant_ids_sql(of_type:, of_ids:, type:)
    reachable_ids_sql direction: :descendant, of_type: of_type, of_ids: of_ids, type: type
  end

  def self.ancestor_ids_sql(of_type:, of_ids:, type:)
    reachable_ids_sql direction: :ancestor, of_type: of_type, of_ids: of_ids, type: type
  end

  # Over which time ranges is the user a member of the group, directly
  # or through any path of subgroups?
  #
  # Validity intersects along each path -- the user is only a member of
  # the corporation through a status group while the user belongs to
  # the status group *and* the status group belongs to the corporation.
  # The per-path ranges union into the returned ranges; gaps stay
  # visible: leaving in 2010 and rejoining in 2015 gives two ranges,
  # and the span between them counts as not a member.
  #
  # Returns an array of Time ranges, beginless or endless where the
  # membership is unbounded.
  #
  def self.membership_validity_ranges(group, user)
    rows = connection.select_rows(<<~SQL)
      WITH RECURSIVE walk(node_type, node_id, validity) AS (
          SELECT l.descendant_type, l.descendant_id, #{link_validity}
            FROM dag_links l
           WHERE l.direct = TRUE
             AND l.ancestor_type = 'Group' AND l.ancestor_id = #{Integer(group.id)}
             AND NOT isempty(#{link_validity})
        UNION ALL
          SELECT l.descendant_type, l.descendant_id, walk.validity * #{link_validity}
            FROM dag_links l
            JOIN walk ON l.ancestor_type = walk.node_type AND l.ancestor_id = walk.node_id
           WHERE l.direct = TRUE
             AND NOT isempty(walk.validity * #{link_validity})
      ) CYCLE node_type, node_id SET is_cycle USING cycle_path
      SELECT lower(validity_range), upper(validity_range)
        FROM unnest((
          SELECT range_agg(validity)
            FROM walk
           WHERE node_type = 'User' AND node_id = #{Integer(user.id)}
             AND NOT is_cycle
        )) AS validity_range
       ORDER BY 1
    SQL
    rows.collect { |from, to| Range.new(parse_bound(from), parse_bound(to)) }
  end

  class << self

    private

    def reachable_ids_of(node_or_nodes, direction:, type:)
      nodes = Array(node_or_nodes)
      return [] if nodes.empty?
      connection.select_values(reachable_ids_sql(
        direction: direction,
        of_type: nodes.first.class.base_class.name,
        of_ids: nodes.collect(&:id),
        type: type.to_s.constantize.base_class.name
      )).collect(&:to_i)
    end

    # UNION deduplicates and thereby terminates on diamonds and cycles.
    # Link validity is deliberately not filtered here: the structural
    # walk includes expired links. Validity scopes live in the
    # Membership layer.
    #
    def reachable_ids_sql(direction:, of_type:, of_ids:, type:)
      from, to = case direction
        when :descendant then ['ancestor', 'descendant']
        when :ancestor then ['descendant', 'ancestor']
        else raise ArgumentError, "direction must be :descendant or :ancestor"
      end
      if of_ids == :all
        id_condition = ""
      else
        ids = of_ids.collect { |id| Integer(id) }
        return "SELECT 1 WHERE FALSE" if ids.empty?
        id_condition = "AND l.#{from}_id IN (#{ids.join(', ')})"
      end
      <<~SQL
        WITH RECURSIVE walk(node_type, node_id) AS (
            SELECT l.#{to}_type, l.#{to}_id
              FROM dag_links l
             WHERE l.direct = TRUE
               AND l.#{from}_type = #{connection.quote(of_type)}
               #{id_condition}
          UNION
            SELECT l.#{to}_type, l.#{to}_id
              FROM dag_links l
              JOIN walk w ON l.#{from}_type = w.node_type AND l.#{from}_id = w.node_id
             WHERE l.direct = TRUE
        )
        SELECT node_id FROM walk WHERE node_type = #{connection.quote(type)}
      SQL
    end

    # Structural links carry no validity dates; NULL means unbounded.
    # Corrupted rows with valid_from > valid_to exist in production and
    # would make tstzrange raise; they count as never valid.
    def link_validity
      "(CASE WHEN l.valid_from IS NOT NULL AND l.valid_to IS NOT NULL AND l.valid_from > l.valid_to" +
      " THEN 'empty'::tstzrange" +
      " ELSE tstzrange(coalesce(l.valid_from, '-infinity'), coalesce(l.valid_to, 'infinity'), '[)') END)"
    end

    # The adapter returns range bounds as Time, or as infinite Float or
    # String for the unbounded ends.
    def parse_bound(value)
      case value
      when nil, Float then nil
      when String then value.include?('infinity') ? nil : Time.zone.parse(value)
      else value.in_time_zone
      end
    end

    def connection
      ActiveRecord::Base.connection
    end

  end

end
