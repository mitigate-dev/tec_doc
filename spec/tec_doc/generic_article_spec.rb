#encoding: utf-8
require "spec_helper"

describe TecDoc::GenericArticle do
  before do
    VCR.use_cassette("generic_article_all") do
      @generic_articles = TecDoc::GenericArticle.all({
        :linking_target_type => "C",
        :linking_target_id => 10502,
        :generic_article_id => { :array => { :id => [7] } },
      })
    end
  end
    
  context ".all" do
    it "should return distinct generic articles" do
      @generic_articles.count.should == 1
      @generic_articles.first.name.should == "Eļļas filtrs"
    end
  end
  
  it "should return all vehicles articles without any options if scope is present" do
    generic_article = TecDoc::GenericArticle.new(:id => 7)
    VCR.use_cassette("article_all") do
      @articles = generic_article.articles
    end
    @articles.count.should == 30
    @articles.map(&:generic_article_id).uniq.should == [ 7 ]
  end
end
