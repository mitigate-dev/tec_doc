require "spec_helper"

describe TecDoc::VehicleManufacturer do
  context ".all" do
    before do
      VCR.use_cassette('vehicle_manufacturer_all') do
        @manufacturers = TecDoc::VehicleManufacturer.all
      end
    end

    it "should return array of manufacturers" do
      @manufacturers.should be_an_instance_of(Array)
      @manufacturers.each do |manufacturer|
        manufacturer.should be_an_instance_of(TecDoc::VehicleManufacturer)
        manufacturer.id.should be_kind_of(Integer)
        manufacturer.id.should > 0
        manufacturer.name.should be_an_instance_of(String)
        manufacturer.name.size.should > 0
      end
    end

    describe "(BMW)" do
      before do
        @manufacturer = @manufacturers.find { |m| m.name == "BMW" }
      end

      context "#models" do
        it "should call TecDoc::VehicleManufacturer.all with manu_id" do
          options = {
            :lang => "lv",
            :car_type => 1,
            :country_group_flag => false,
            :countries_car_selection => "lv",
            :eval_favor => false
          }
          TecDoc::VehicleModel.should_receive(:all).with(options.merge(:manu_id => @manufacturer.id)).and_return(Array.new)
          models = @manufacturer.models(options)
          models.should be_an_instance_of(Array)
        end
      end
    end
  end
end
