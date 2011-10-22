require "spec_helper"

describe TecDoc::AssemblyGroup do
  context ".all" do
    before do
      VCR.use_cassette('assembly_group_all') do
        @groups = TecDoc::AssemblyGroup.all(
          :lang => "lv",
          :child_nodes => false,
          :linking_target_type => "C"
        )
      end
    end

    it "should return array of groups" do
      @groups.should be_an_instance_of(Array)
      @groups.each do |group|
        group.should be_an_instance_of(TecDoc::AssemblyGroup)
        group.id.should be_kind_of(Integer)
        group.id.should > 0
        group.name.should be_an_instance_of(String)
        group.name.size.should > 0
        group.parent_id.should be_nil
      end
    end

    context "#children" do
      before do
        @parent = @groups.first
        VCR.use_cassette('assembly_group_children') do
          @children = @parent.children
        end
      end

      it "should have children" do
        @children.should be_an_instance_of(Array)
        @children.each do |group|
          group.should be_an_instance_of(TecDoc::AssemblyGroup)
          group.id.should be_kind_of(Integer)
          group.id.should > 0
          group.name.should be_an_instance_of(String)
          group.name.size.should > 0
          group.parent_id.should == @parent.id
          group.parent.should == @parent
        end
      end
    end
  end
end
