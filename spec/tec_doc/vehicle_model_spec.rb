require "spec_helper"

describe TecDoc::VehicleModel do
  context ".all" do
    before do
      VCR.use_cassette('vehicle_model_all') do
        @models = TecDoc::VehicleModel.all(
          :car_type => 1,
          :country_group_flag => false,
          :manu_id => 16, # BMW
          :eval_favor => false
        )
      end
    end

    it "should return array of models" do
      @models.should be_an_instance_of(Array)
      @models.each do |model|
        model.should be_an_instance_of(TecDoc::VehicleModel)
        model.id.should be_kind_of(Integer)
        model.id.should > 0
        model.name.should be_an_instance_of(String)
        model.name.size.should > 0
      end
    end

    describe "(BMW, 3 (E36))" do
      it "should have construction dates" do
        model = @models.find { |m| m.name == "3 (E36)" }
        model.date_of_construction_from.should == Date.new(1990, 9, 1)
        model.date_of_construction_to.should == Date.new(1998, 2, 1)
      end
    end
  end
end
