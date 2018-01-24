# This is a patch for rails-erd to prevent
# "Verify that Graphviz is installed and in your path, or use filetype=dot."
#
# Credit: https://github.com/voormedia/rails-erd/issues/70#issuecomment-63645855
# See also: https://github.com/voormedia/rails-erd/issues/278
#
# Trello: https://trello.com/c/ZAxCtj5W/1233-entity-relationship

require 'rails_erd/domain/relationship'

module RailsERD
  class Domain
    class Relationship
      class << self
        private

        def association_identity(association)
          Set[association_owner(association), association_target(association)]
        end
      end
    end
  end
end