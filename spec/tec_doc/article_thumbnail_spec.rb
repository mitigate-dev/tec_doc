require "spec_helper"

describe TecDoc::ArticleThumbnail do
  context ".all" do
    before do
      VCR.use_cassette('article_thumbnail_all') do
        @thumbnails = TecDoc::ArticleThumbnail.all(:article_id => 201756)
      end
    end

    it "should return array of thumbnails" do
      @thumbnails.should be_an_instance_of(Array)
      @thumbnails.size.should > 0
      @thumbnails.each do |thumbnail|
        thumbnail.should be_an_instance_of(TecDoc::ArticleThumbnail)
        thumbnail.id.should be_kind_of(Integer)
        thumbnail.id.should > 0
        thumbnail.file_name.should be_an_instance_of(String)
        thumbnail.file_name.size.should > 0
        thumbnail.type_id.should be_kind_of(Integer)
        thumbnail.type_id.size.should > 0
      end
    end

    describe "#content" do
      it "should return picture" do
        thumbnail = @thumbnails[0]
        VCR.use_cassette('article_thumbnail_content') do
          thumbnail.content.should include("JFIF")
        end
      end
    end
  end
end
