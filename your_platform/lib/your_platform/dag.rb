# Vendored from the acts-as-dag fork, v4.0.0:
# https://github.com/fiedl/acts-as-dag, branch sf/rails-5,
# revision 5e185dd, MIT license (see dag/MIT-LICENSE).
#
# Vendoring lets the closure-table DSL be edited in-repo while it is
# replaced by recursive CTE queries, step by step:
# https://github.com/fiedl/wingolfsplattform/issues/129

require 'active_model'
require 'active_record'

require_relative 'dag/dag'
require_relative 'dag/columns'
require_relative 'dag/poly_columns'
require_relative 'dag/polymorphic'
require_relative 'dag/standard'
require_relative 'dag/edges'
require_relative 'dag/validators'

ActiveRecord::Base.extend Dag
