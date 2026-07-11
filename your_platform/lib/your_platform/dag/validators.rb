# Vendored from acts-as-dag. Corresponding upstream file:
# https://github.com/resgraph/acts-as-dag/blob/master/lib/dag/validators.rb
#
module Dag

  # Validations on link creation. Ensures no duplicate edges and no
  # cycles. Only direct links can be created: transitive links are not
  # materialized anymore but derived by recursive CTEs (Dag::Traversal).
  # https://github.com/fiedl/wingolfsplattform/issues/129
  class CreateCorrectnessValidator < ActiveModel::Validator

    def validate(record)
      record.errors[:base] << 'Link must start and end in different places' if has_short_cycles(record)
      record.errors[:base] << 'Link would create a cycle' if has_long_cycles(record)
      record.errors[:base] << 'Only direct links can be created' unless record.direct?
    end

    private

    # The closure's implicit cycle protection is gone; walk the direct
    # links to make sure the new edge's descendant cannot already
    # reach its ancestor.
    def has_long_cycles(record)
      Dag::Traversal.descendant_ids(
        of_type: record.descendant_type, of_ids: [record.descendant_id],
        type: record.ancestor_type
      ).include?(record.ancestor_id)
    end

    def has_short_cycles(record)
      record.sink.matches?(record.source)
    end
  end

  # Validations on update: the graph columns of an existing link are
  # immutable; validity and flag columns may change freely.
  class UpdateCorrectnessValidator < ActiveModel::Validator

    def validate(record)
      record.errors[:base] << "No changes" unless record.changed?
      record.errors[:base] << "The direct flag cannot change; create or destroy the link instead" if record.direct_changed?
    end

  end

end
