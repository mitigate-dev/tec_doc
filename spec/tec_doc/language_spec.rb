require "spec_helper"

describe TecDoc::Language do
  context ".all" do
    before do
      VCR.use_cassette('language_all') do
        @languages = TecDoc::Language.all(:lang => "lv")
      end
    end

    it "should return array of languages" do
      @languages.should be_an_instance_of(Array)
      @languages.each do |language|
        language.should be_an_instance_of(TecDoc::Language)
        language.code.should be_an_instance_of(String)
        language.code.size.should > 0
        language.name.should be_an_instance_of(String)
        language.name.size.should > 0
      end
    end
  end
end
