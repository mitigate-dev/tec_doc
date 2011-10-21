require "spec_helper"

describe TecDoc::Language do
  use_vcr_cassette

  context ".all" do
    it "should return array of languages" do
      languages = TecDoc::Language.all(:lang => "lv")
      languages.should be_an_instance_of(Array)
      languages.each do |language|
        language.should be_an_instance_of(TecDoc::Language)
        language.code.should be_an_instance_of(String)
        language.code.size.should > 0
        language.name.should be_an_instance_of(String)
        language.name.size.should > 0
      end
    end
  end
end
