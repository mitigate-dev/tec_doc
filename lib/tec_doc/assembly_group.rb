module TecDoc
  class AssemblyGroup
    attr_accessor :id, :parent_id, :name, :has_children, :parent
    attr_writer :children

    attr_accessor :scope

    def initialize(attributes={})
      @id = attributes[:assembly_group_node_id].to_i
      @name = attributes[:assembly_group_name].to_s
      @has_children = attributes[:has_childs]
      @scope = attributes[:scope]
      if attributes[:parent_node_id]
        @parent_id = attributes[:parent_node_id].to_i
      end
    end

    # Find vehicle, axle, motor or universal assembly groups for the search tree
    #
    # @option options [TrueClass, FalseClass] :child_nodes include child nodes
    # @option options [String] :lang language code according to ISO 639
    # @option options [String] :linking_target_type linking target (C: Vehicle type, M: Motor, A: Axle, K: Body Type, U: Universal)
    # @option options [Integer] :parent_node_id parent node id (optional)
    # @return [Array<TecDoc::AssemblyGroup>] list of languages
    def self.all(options = {})
      options = {
        :lang => I18n.locale.to_s
      }.merge(options)

      options[:country] ||= TecDoc.client.country
      response = TecDoc.client.request(:getChildNodesAllLinkingTarget2, options)

      groups = response.map do |attributes|
        attributes[:scope] = options
        new(attributes)
      end

      if options[:child_nodes]
        group_ids_map = {}
        groups.each do |group|
          group_ids_map[group.id] = group
        end
        groups.each do |group|
          parent = group_ids_map[group.parent_id]
          if parent
            parent.add_child(group)
          end
        end
      end

      groups
    end

    def children
      @children ||= if has_children
        self.class.
          all(scope.merge(:parent_node_id => id)).
          each { |child| child.parent = self }
      else
        []
      end
    end

    def add_child(child)
      @children ||= []
      @children << child
    end

    def inspect
      "#<#{self.class} @id=#{id.inspect}, @parent_id=#{parent_id.inspect}, @name=#{name.inspect}, @has_children=#{has_children.inspect}>"
    end
  end
end
