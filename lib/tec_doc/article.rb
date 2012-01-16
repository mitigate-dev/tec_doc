require "tec_doc/helpers/date_parser_helper"

module TecDoc
  class Article
    include Helpers::DateParserHelper
    
    attr_accessor :id, :name, :number, :search_number, :brand_name, :brand_number, :generic_article_id, :number_type

    attr_accessor :scope

    # Find article by all number types and brand number and generic article id.
    # 
    # @option options [String] :article_number Article number will be converted within the search process to a simplified article number
    # @option options [Integer] :brand_no result of brand selection (optional)
    # @option options [String] :country country code according to ISO 3166
    # @option options [Integer] :generic_article_id result of generic article selection (optional)
    # @option options [String] :lang language code according to ISO 639
    # @option options [String] :number_type Number type (0: Article number, 1: OE number, 2: Trade number, 3: Comparable number, 4: Replacement number, 5: Replaced number, 6: EAN number, 10: Any number)
    # @option options [TrueClass, FalseClass] :search_exact Search mode (true: exact search, false: similar searc)
    # @option options [Integer] :sort_type Sort mode (1: Brand, 2: Product group)
    # @return [Array<TecDoc::Article>] list of articles
    def self.search(options = {})
      response = TecDoc.client.request(:get_article_direct_search_all_numbers2, options)
      response.map do |attributes|
        article = new
        article.scope = options
        article.id                 = attributes[:article_id].to_i
        article.name               = attributes[:article_name].to_s
        article.number             = attributes[:article_no].to_s
        article.brand_name         = attributes[:brand_name].to_s
        article.brand_number       = attributes[:brand_no].to_s
        article.generic_article_id = attributes[:generic_article_id].to_i
        article.number_type        = attributes[:number_type].to_i
        article.search_number      = attributes[:article_search_no].to_s
        article
      end
    end

    def brand
      unless defined?(@brand)
        @brand = Brand.new
        @brand.number = brand_number
        @brand.name = brand_name
      end
      @brand
    end

    def documents
      @documents ||= ArticleDocument.all({
        :lang => scope[:lang],
        :country => scope[:country],
        :article_id => id
      })
    end

    def thumbnails
      @thumbnails ||= ArticleThumbnail.all(:article_id => id)
    end

    def attributes
      @attributes ||= assigned_article[:article_attributes].map do |attrs|
        ArticleAttribute.new(attrs)
      end
    end

    def ean_number
      @ean_number ||= assigned_article[:ean_number].map(&:values).flatten.first
    end

    def oe_numbers
      @oe_numbers ||= assigned_article[:oen_numbers].map do |attrs|
        ArticleOENumber.new(attrs)
      end
    end
    
    def linked_manufacturers
      unless @linked_manufacturers
        response = TecDoc.client.request(:get_article_linked_all_linking_target_manufacturer, {
          :country => scope[:country],
          :linking_target_type => "C",
          :article_id => id
        })
        @linked_manufacturers = response.map do |attrs|
          manufacturer = VehicleManufacturer.new
          manufacturer.name = attrs[:manu_name].to_s
          manufacturer.id = attrs[:manu_id].to_i
          manufacturer
        end
      end
      @linked_manufacturers
    end
    
    def linked_vehicle_ids
      @linked_vehicle_ids ||= TecDoc.client.request(:get_article_linked_all_linking_target_2, {
        :lang => scope[:lang],
        :country => scope[:country],
        :linking_target_type => "C",
        :linking_target_id => -1,
        :article_id => id
      }).map{ |attrs| attrs[:linking_target_id].to_i }.uniq
    end
    
    def linked_vehicles(options = {})
      unless @linked_vehicles
        batch_list = linked_vehicle_ids.each_slice(25).to_a
        
        # Response from all batches
        response = batch_list.inject([]) do |result, long_list|
          result += TecDoc.client.request(:get_vehicle_by_ids_2,
            {:car_ids => {
              :array => {:ids => long_list}
            },
            :lang => scope[:lang],
            :country => scope[:country],
            :country_user_setting => scope[:country],
            :countries_car_selection => scope[:country],
            :motor_codes => false,
            :axles => false,
            :cabs => false,
            :secondary_types => false,
            :vehicle_details2 => true,
            :vehicle_terms => false,
            :wheelbases => false
          })
          result
        end
        
        @linked_vehicles = response.map do |attrs|
          details = (attrs[:vehicle_details2] || {})
          vehicle = Vehicle.new
          vehicle.id = attrs[:car_id].to_i
          vehicle.name = "#{details[:manu_name]} - #{details[:model_name]} - #{details[:type_name]}"
          vehicle.power_hp_from             = details[:power_hp].to_i
          vehicle.power_kw_from             = details[:power_kw].to_i
          vehicle.date_of_construction_from = parse_tec_doc_date details[:year_of_construction_from]
          vehicle.date_of_construction_to   = parse_tec_doc_date details[:year_of_construction_to]
          vehicle
        end
      end
      @linked_vehicles
    end

    private

    def assigned_article
      @assigned_article ||= TecDoc.client.request(:get_assigned_articles_by_ids2_single, {
        :lang => scope[:lang],
        :country => scope[:country],
        :linking_target_type => "U",
        :article_id => id,
        :attributs => true,
        :ean_numbers => true,
        :oe_numbers => true
      })[0]
    end
  end
end
