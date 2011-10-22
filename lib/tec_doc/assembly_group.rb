module TecDoc
  class AssemblyGroup
    attr_accessor :id, :parent_id, :name, :has_children, :parent
    attr_writer :children

    attr_accessor :scope

    # TODO Handle :child_nodes true
    # 
    # Find vehicle, axle, motor or universal assembly groups for the search tree
    # 
    # @option options [TrueClass, FalseClass] :child_nodes include child nodes
    # @option options [String] :lang language code according to ISO 639
    # @option options [String] :linking_target_type linking target (C: Vehicle type, M: Motor, A: Axle, K: Body Type, U: Universal)
    # @option options [Integer] :parent_node_id parent node id (optional)
    # @return [Array<TecDoc::AssemblyGroup>] list of languages
    def self.all(options = {})
      response = TecDoc.client.request(:get_child_nodes_all_linking_target2, options)
      response.to_hash[:get_child_nodes_all_linking_target2_response][:get_child_nodes_all_linking_target2_return][:data][:array][:array].map do |attributes|
        group = new
        group.scope = options
        group.id = attributes[:assembly_group_node_id].to_i
        group.name = attributes[:assembly_group_name].to_s
        group.has_children = attributes[:has_childs]
        if attributes[:parent_node_id]
          group.parent_id = attributes[:parent_node_id].to_i
        end
        group
      end
    end

    def children
      if has_children
        @children ||= self.class.
          all(scope.merge(:parent_node_id => id)).
          each { |child| child.parent = self }
      else
        []
      end
    end

    def inspect
      "#<#{self.class} @id=#{id.inspect}, @parent_id=#{parent_id.inspect}, @name=#{name.inspect}, @has_children=#{has_children.inspect}>"
    end
  end
end
