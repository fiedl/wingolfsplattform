module ActiveRecord
  class Relation
    module WhereClauseOverrides
      def predicates_except(columns)
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
