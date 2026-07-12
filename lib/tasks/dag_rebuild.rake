# Break-glass rollback tooling: rebuilds the materialized closure rows
# (direct: false, with path counts and membership validity envelopes)
# from the direct links, in case a rollback to a release that still
# reads them becomes necessary.
# https://github.com/fiedl/wingolfsplattform/issues/129
#
#     rails dag:rebuild_indirect_rows
#
namespace :dag do
  task rebuild_indirect_rows: :environment do
    pairs = ActiveRecord::Base.connection.select_rows(<<~SQL)
      WITH RECURSIVE walk(a_type, a_id, d_type, d_id, depth) AS (
          SELECT ancestor_type, ancestor_id, descendant_type, descendant_id, 1
            FROM dag_links WHERE direct = TRUE
        UNION ALL
          SELECT w.a_type, w.a_id, l.descendant_type, l.descendant_id, w.depth + 1
            FROM dag_links l
            JOIN walk w ON l.ancestor_type = w.d_type AND l.ancestor_id = w.d_id
           WHERE l.direct = TRUE AND w.depth < 50
      )
      SELECT a_type, a_id, d_type, d_id, count(*), bool_or(depth = 1)
        FROM walk GROUP BY 1, 2, 3, 4
    SQL

    created = 0
    updated = 0
    pairs.each do |ancestor_type, ancestor_id, descendant_type, descendant_id, path_count, has_direct|
      if has_direct
        DagLink.where(ancestor_type: ancestor_type, ancestor_id: ancestor_id,
          descendant_type: descendant_type, descendant_id: descendant_id, direct: true)
          .update_all(count: path_count)
        updated += 1
      else
        next if DagLink.where(ancestor_type: ancestor_type, ancestor_id: ancestor_id,
          descendant_type: descendant_type, descendant_id: descendant_id, direct: false).exists?
        link = DagLink.new ancestor_type: ancestor_type, ancestor_id: ancestor_id,
          descendant_type: descendant_type, descendant_id: descendant_id
        link[:direct] = false
        link[:count] = path_count
        link.send :change_type_according_to_other_attributes
        if link.type.to_s.start_with?('Membership')
          derived = IndirectMembership.new Group.find(ancestor_id), User.find(descendant_id)
          link.valid_from = derived.valid_from
          link.valid_to = derived.valid_to
        end
        link.save validate: false
        created += 1
        print '.'
      end
    end
    puts "\n#{created} indirect rows created, #{updated} direct counts updated."
  end
end
