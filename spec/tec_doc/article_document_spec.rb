require "spec_helper"

describe TecDoc::ArticleDocument do
  context ".all" do
    before do
      VCR.use_cassette('article_document_all') do
        @documents = TecDoc::ArticleDocument.all(:article_id => 201756, :country => "lv", :lang => "lv")
      end
    end

    it "should return array of documents" do
      @documents.should be_an_instance_of(Array)
      @documents.size.should > 0
      @documents.each do |document|
        document.should be_an_instance_of(TecDoc::ArticleDocument)
        document.id.should be_kind_of(Integer)
        document.id.should > 0
        document.file_name.should be_an_instance_of(String)
        document.file_name.size.should > 0
        document.type_id.should be_kind_of(Integer)
        document.type_id.size.should > 0
      end
    end

    describe "#content" do
      it "should return picture" do
        document = @documents[0]
        VCR.use_cassette('article_document_content') do
          document.content.should include("JFIF")
        end
      end
    end
  end
end
