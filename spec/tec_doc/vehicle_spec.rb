#encoding: utf-8
require "spec_helper"

describe TecDoc::Vehicle do
  context ".all" do
    before do
      VCR.use_cassette('vehicle_all') do
        @vehicles = TecDoc::Vehicle.all(
          :car_type => 1,
          :country_group_flag => false,
          :country_user_setting => TecDoc.client.country,
          :manu_id => 16, # BMW
          :mod_id => 3999, # E46 Coupe
          :linked => false,
          :favoured_list => 1
        )
      end
    end

    it "should return array of vehicles" do
      @vehicles.should be_an_instance_of(Array)
      @vehicles.each do |model|
        model.should be_an_instance_of(TecDoc::Vehicle)
        model.id.should be_kind_of(Integer)
        model.id.should > 0
        model.name.should be_an_instance_of(String)
        model.name.size.should > 0
      end
    end

    describe "(BMW, 3 Coupe E46, 323 Ci)" do
      it "should have construction dates" do
        vehicle = @vehicles.find { |m| m.id == 10502 }
        vehicle.name.should == "323 Ci"
        vehicle.cylinder_capacity.should == 2494
        vehicle.first_country.should == "LV"
        vehicle.date_of_construction_from.should == Date.new(1999, 4, 1)
        vehicle.date_of_construction_to.should == Date.new(2000, 9, 1)
        vehicle.power_hp_from.should == 170
        vehicle.power_hp_to.should == 170
        vehicle.power_kw_from.should == 125
        vehicle.power_kw_to.should == 125
        vehicle.motor_codes.should == ["M52 B25 (Vanos)"]
      end
      
      it "should return root linked assembly groups" do
        @vehicle = @vehicles.find { |m| m.id == 10502 }
        VCR.use_cassette('vehicle_assembly_groups') do
          @assembly_groups = @vehicle.assembly_groups
        end
        @assembly_groups.count.should == 29
        @assembly_groups.first.class.should == TecDoc::AssemblyGroup
        @assembly_groups.any?{ |group| group.name == "Dzesēšanas sistēma" }.should be_true
      end
      
      it "should return all child assembly groups" do
        @vehicle = TecDoc::Vehicle.new
        @vehicle.id = 10502
        VCR.use_cassette('vehicle_child_assembly_groups') do
          @assembly_groups = @vehicle.assembly_groups(100005)
        end
        @assembly_groups.count.should == 5
        @assembly_groups.any?{ |group| group.name == "Gaisa filtrs" }.should be_true
      end
    end
  end
end
