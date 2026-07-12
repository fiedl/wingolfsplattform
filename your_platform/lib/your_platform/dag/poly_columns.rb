# Vendored from acts-as-dag. Corresponding upstream file:
# https://github.com/resgraph/acts-as-dag/blob/master/lib/dag/poly_columns.rb
#
module Dag
  #Methods that show the columns for polymorphic DAGs
  module PolyColumns
    def ancestor_type_column_name
      acts_as_dag_options[:ancestor_type_column]
    end

    def descendant_type_column_name
      acts_as_dag_options[:descendant_type_column]
    end
  end
end