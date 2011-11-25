require "spec_helper"

describe TecDoc::Article do
  context ".search" do
    before do
      VCR.use_cassette('article_search') do
        @articles = TecDoc::Article.search(
          :article_number => "31966",
          :number_type => 10,
          :lang => "lv",
          :country => "lv",
          :sort_type => 1,
          :search_exact => false,
          :brandno => nil,
          :generic_article_id => nil
        )
      end
    end

    it "should return array of articles" do
      @articles.should be_an_instance_of(Array)
      @articles.each do |article|
        article.should be_an_instance_of(TecDoc::Article)
        article.id.should be_kind_of(Integer)
        article.id.should > 0
        article.name.should be_an_instance_of(String)
        article.name.size.should > 0
      end
    end
  end
end
