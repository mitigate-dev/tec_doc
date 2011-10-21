require "spec_helper"

describe TecDoc::Brand do
  use_vcr_cassette

  context ".all" do
    it "should return array of brands" do
      brands = TecDoc::Brand.all
      brands.should be_an_instance_of(Array)
      brands.each do |brand|
        brand.should be_an_instance_of(TecDoc::Brand)
        brand.number.should be_kind_of(Integer)
        brand.number.should > 0
        brand.name.should be_an_instance_of(String)
        brand.name.size.should > 0
      end
    end
  end
end
