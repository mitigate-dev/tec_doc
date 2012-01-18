require "spec_helper"

describe TecDoc::GenericArticle do 
  it "should return all vehicles articles" do
    generic_article = TecDoc::GenericArticle.new
    generic_article.id = 7
    VCR.use_cassette("article_all") do
      @articles = generic_article.articles(
        :linking_target_type => "C",
        :linking_target_id => 10502
      )
    end
    @articles.count.should == 30
    @articles.map(&:generic_article_id).uniq.should == [ 7 ]
  end
end
