require "spec_helper"

describe TecDoc::DateParser do
  describe "#to_date" do
    it "should convert 199904 to April 1st, 1999" do
      TecDoc::DateParser.new("199904").to_date.should == Date.new(1999, 4, 1)
    end

    it "should convert 201012 to December 1st, 2012" do
      TecDoc::DateParser.new("201012").to_date.should == Date.new(2010, 12, 1)
    end

    it "should return nil when nil" do
      TecDoc::DateParser.new(nil).to_date.should == nil
    end
  end
end
