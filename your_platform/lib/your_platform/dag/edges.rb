module Dag
  module Edges

    def self.included(base)
      base.send :include, EdgeInstanceMethods
    end

    #Class methods that extend the link model for both polymorphic and non-polymorphic graphs
    #Returns a new edge between two points
    def build_edge(ancestor, descendant)
      source = self::EndPoint.from(ancestor)
      sink = self::EndPoint.from(descendant)
      conditions = self.conditions_for(source, sink)
      path = self.new(conditions)
      path.make_direct
      path
    end

    #Finds an edge between two points, Must be direct
    def find_edge(ancestor, descendant)
      source = self::EndPoint.from(ancestor)
      sink = self::EndPoint.from(descendant)
      self.where(self.conditions_for(source, sink).merge!({direct_column_name => true})).first
    end

    #Finds a link between two points
    def find_link(ancestor, descendant)
      source = self::EndPoint.from(ancestor)
      sink = self::EndPoint.from(descendant)
      self.where(self.conditions_for(source, sink)).first
    end

    #Finds or builds an edge between two points
    def find_or_build_edge(ancestor, descendant)
      edge = self.find_edge(ancestor, descendant)
      return edge unless edge.nil?
      return build_edge(ancestor, descendant)
    end

    #Creates an edge between two points using save
    def create_edge(ancestor, descendant)
      link = self.find_link(ancestor, descendant)
      if link.nil?
        edge = self.build_edge(ancestor, descendant)
        return edge.save
      else
        link.make_direct
        return link.save
      end
    end

    #Creates an edge between two points using save! Returns created edge
    def create_edge!(ancestor, descendant)
      link = self.find_link(ancestor, descendant)
      if link.nil?
        edge = self.build_edge(ancestor, descendant)
        edge.save!
        edge
      else
        link.make_direct
        link.save!
        link
      end
    end

    #Finds the longest path between ancestor and descendant returning as an array
    def longest_path_between(ancestor, descendant, path=[])
      longest = []
      ancestor.children.each do |child|
        if child == descendant
          temp = path.clone
          temp << child
          if temp.length > longest.length
            longest = temp
          end
        elsif self.find_link(child, descendant)
          temp = path.clone
          temp << child
          temp = self.longest_path_between(child, descendant, temp)
          if temp.length > longest.length
            longest = temp
          end
        end
      end
      longest
    end

    #Finds the shortest path between ancestor and descendant returning as an array
    def shortest_path_between(ancestor, descendant, path=[])
      shortest = []
      ancestor.children.each do |child|
        if child == descendant
          temp = path.clone
          temp << child
          if shortest.blank? || temp.length < shortest.length
            shortest = temp
          end
        elsif self.find_link(child, descendant)
          temp = path.clone
          temp << child
          temp = self.shortest_path_between(child, descendant, temp)
          if shortest.blank? || temp.length < shortest.length
            shortest = temp
          end
        end
      end
      return shortest
    end

    #Determines if an edge exists between two points
    def edge?(ancestor, descendant)
      !self.find_edge(ancestor, descendant).nil?
    end

    #Alias for edge
    def direct?(ancestor, descendant)
      self.edge?(ancestor, descendant)
    end

    #Instance methods included into the link model for polymorphic and non-polymorphic DAGs
    module EdgeInstanceMethods

      #Fill default direct and count values if necessary. In place of after_initialize method
      def fill_defaults
        self[direct_column_name] = true if self[direct_column_name].nil?
        self[count_column_name] = 0 if self[count_column_name].nil?
      end

      # Without the materialized closure, every link is a plain direct
      # edge and can always be destroyed. The method remains for the
      # callers that guarded destruction in the closure days.
      def destroyable?
        true
      end

      #Id of the ancestor
      def ancestor_id
        self[ancestor_id_column_name]
      end

      #Id of the descendant
      def descendant_id
        self[descendant_id_column_name]
      end

      #Count of the edge, ie the edge exists in X ways
      def count
        self[count_column_name]
      end

      #Changes the count of the edge. DO NOT CALL THIS OUTSIDE THE PLUGIN
      def internal_count=(val)
        self[count_column_name] = val
      end

      #Whether the link is direct, ie manually created
      def direct?
        self[direct_column_name]
      end

      #Whether the link is an edge?
      def edge?
        self[direct_column_name]
      end

      #Makes the link direct, ie an edge
      def make_direct
        self[direct_column_name] = true
      end

      #Makes an edge indirect, ie a link.
      def make_indirect
        self[direct_column_name] = false
      end

      #Source of the edge, creates if necessary
      def source
        @source = self.class::Source.from_edge(self) if @source.nil?
        @source
      end

      #Sink (destination) of the edge, creates if necessary
      def sink
        @sink = self.class::Sink.from_edge(self) if @sink.nil?
        @sink
      end

      #All links that end at the source
      def links_to_source
        self.class.with_descendant_point(self.source)
      end

      #all links that start from the sink
      def links_from_sink
        self.class.with_ancestor_point(self.sink)
      end
    end

  end
end