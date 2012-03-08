#encoding: utf-8
require "spec_helper"

describe TecDoc::Article do
  context ".search" do
    before do
      VCR.use_cassette('article_search') do
        @articles = TecDoc::Article.search(
          :article_number => "31966",
          :number_type => 10,
          :search_exact => false
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
        article.search_number.size.should > 0
      end
    end

    context "#article_details" do
      before do
        @article = @articles.detect { |a| a.brand_name == "FEBI BILSTEIN" && a.number == "31966" }
        VCR.use_cassette('article_details') do
          @article.send(:article_details)
        end
      end

      it "should have EAN number" do
        @article.ean_number.should == "4027816319665"
      end
      
      it "should have information" do
        VCR.use_cassette("article_information") do
          @article.send(:direct_article_data_en)
        end
        @article.information[0][:info_text].should == "for air conditioning"
      end
      
      context "with state and trade number" do
        before do
          VCR.use_cassette('article_trade_number') do
            @article = TecDoc::Article.search(
              :article_number => "4PK1217",
              :number_type => 0,
              :search_exact => true
            )[0]
          end
          
          VCR.use_cassette('article_details_for_trade_number') do
            @article.send(:article_details)
          end
        end
      
        it "should have state" do
          @article.state.should == "Normāls"
        end

        it "should have trade number" do
          @article.trade_numbers.should == "4 PK 1216, 4 PK 1217, 4 PK 1218, 4 PK 1219"
        end
      end

      it "should have OE numbers" do
        @article.oe_numbers.size.should > 0
        @article.oe_numbers.each do |oe_number|
          oe_number.should be_an_instance_of(TecDoc::ArticleOENumber)
          oe_number.brand_name.should == "BMW"
          oe_number.oe_number.should be_an_instance_of(String)
          oe_number.oe_number.size.should > 0
        end
      end

      it "should have attributes" do
        @article.attributes.size.should > 0
        @article.attributes.each do |attribute|
          attribute.name.should be_an_instance_of(String)
          attribute.name.size.should > 0
          attribute.value.should be_an_instance_of(String)
          attribute.value.size.should > 0
        end
      end
    end
  end

  context ".all" do
    it "should return all vehicles articles with specified generic article" do
      VCR.use_cassette('article_all') do
        @articles = TecDoc::Article.all(
          :linking_target_type => "C",
          :linking_target_id => 10502,
          :generic_article_id => { :array => {:id => [7] } }
        )
      end
      
      @articles.count.should == 30
      @articles.map(&:generic_article_id).uniq.should == [7]
    end
  end

  context ".all_with_details" do
    it "should get all article detail information in and set it to articles" do
      VCR.use_cassette("article_all_with_details") do
        @articles = TecDoc::Article.all_with_details(:ids => [208662, 212551])
      end

      @articles.each do |article|
        ["07642101", "07642077"].include?(article.instance_variable_get(:@trade_number))
        article.instance_variable_get(:@attributes).to_a.empty?.should be_false
        article.id.should_not be_nil
        article.number.should_not be_nil
        article.brand_number.should_not be_nil
      end
    end
  end

  context "for linked_manufacturers and linked vehicles" do
    before do
      VCR.use_cassette('article_search_for_linked_manufacturers') do
        @articles = TecDoc::Article.search(
          :article_number => "4PK1025",
          :number_type => 0,
          :search_exact => true
        )
      end
    end

    it "should return array of linked manufacturers" do
      VCR.use_cassette('article_linked_manufacturers') do
        @articles[0].linked_manufacturers
      end
      @articles[0].linked_manufacturers.map(&:name).should == ["CITRO","HONDA","NISSA","SUZUK"]
    end

    it "should return array of linked vehicle ids" do
      VCR.use_cassette('article_linked_vehicle_ids') do
        @articles[0].linked_vehicle_ids
      end
      @articles[0].linked_vehicle_ids.count.should == 16
    end

    it "should return array of linked vehicles" do
      VCR.use_cassette('article_linked_vehicles') do
        @articles[0].linked_vehicles
      end
      @articles[0].linked_vehicles.count.should == 30
      @articles[0].linked_vehicles.map(&:motor_codes).flatten.uniq.include?("A 18 XER").should be_true
      @articles[0].linked_vehicles.first.class.should == TecDoc::Vehicle
    end

    it "should return article linked vehicle with details" do
      VCR.use_cassette('article_linked_vehicles_with_details') do
        @articles[0].linked_vehicles_with_details
      end

      vehicle = @articles[0].linked_vehicles_with_details.detect{ |v| v.name =~ /HYUNDAI/i }
      vehicle.attributes.length.should == 3

      attribute = vehicle.attributes[0]
      puts "\n\n\n", vehicle.attributes.inspect
      attribute[:attr_name].should == "Sākot ar izlaiduma gadu"
      attribute[:attr_value].should == "199207"
    end
  end
end
