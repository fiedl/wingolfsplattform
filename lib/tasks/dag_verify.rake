# Verifies on a real database -- typically a production dump -- that the
# recursive CTE walk reaches the same nodes as the materialized closure
# rows, before the closure maintenance is removed:
# https://github.com/fiedl/wingolfsplattform/issues/129
#
#     rails dag:verify_cte_parity
#     SAMPLE=500 rails dag:verify_cte_parity
#
# Differences are stale closure rows: the closure is not maintained
# anymore and only remains until the indirect rows are deleted.
#
namespace :dag do
  task verify_cte_parity: :environment do
    sample_size = (ENV['SAMPLE'] || 200).to_i
    mismatches = []
    checks = 0

    node_classes = [Group, User, Page, Event, Project, Post, Workflow]
    node_classes.each do |node_class|
      scope = node_class.all
      nodes = scope.count > sample_size ? scope.order(Arel.sql('random()')).limit(sample_size) : scope
      nodes.each do |node|
        node_type = node.class.base_class.name
        %w(groups users pages events projects posts workflows).each do |table|
          target_type = table.classify.constantize.base_class.name
          [:descendant, :ancestor].each do |direction|
            accessor = "#{direction}_#{table}"
            next unless node.respond_to?(accessor)
            closure_ids = if direction == :descendant
              DagLink.where(ancestor_type: node_type, ancestor_id: node.id,
                descendant_type: target_type).pluck(:descendant_id)
            else
              DagLink.where(descendant_type: node_type, descendant_id: node.id,
                ancestor_type: target_type).pluck(:ancestor_id)
            end.uniq.sort
            cte_ids = node.send(accessor).pluck(:id).uniq.sort
            checks += 1
            unless closure_ids == cte_ids
              mismatches << "#{node.class}##{node.id} #{accessor}: " +
                "closure-only #{(closure_ids - cte_ids).inspect}, cte-only #{(cte_ids - closure_ids).inspect}"
            end
          end
        end
        print '.'
      end
    end

    puts "\n#{checks} comparisons."
    if mismatches.any?
      puts "#{mismatches.count} MISMATCHES:"
      mismatches.each { |m| puts "  #{m}" }
      exit 1
    else
      puts "No mismatches. The CTE walk agrees with the closure."
    end
  end
end
