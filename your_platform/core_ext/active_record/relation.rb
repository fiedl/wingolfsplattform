module ActiveRecord
  class Relation

    # `unscope(where: :column)` only removes hash/equality conditions.
    # Our validity-range scopes build string conditions like
    # 'valid_from IS NULL OR valid_from <= ?', which rails would leave
    # in place. This override also drops String and Grouping predicates
    # that mention the unscoped column, so `with_invalid` really widens
    # the query. See MembershipValidityRange.
    #
    module WhereClauseOverrides
      # Rails named this hook predicates_except in 5.0 and renamed it
      # to except_predicates in 5.1. Missing the rename silently turns
      # `with_invalid` into a no-op — expired memberships vanish from
      # queries. (Caught by group_memberships_spec on the 5.1 hop.)
      def except_predicates(columns)
        super.reject do |node|
          case node
          when Arel::Nodes::Grouping
            sql = node.to_sql
            columns.any? { |column| sql.match? /\b#{column}\b/ }
          when String
            columns.any? { |column| node.match? /\b#{column}\b/ }
          end
        end
      end
    end

    class WhereClause
      prepend WhereClauseOverrides
    end
  end
end
