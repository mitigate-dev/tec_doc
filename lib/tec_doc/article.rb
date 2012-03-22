module TecDoc
  class Article
    attr_accessor :id, :name, :number, :search_number, :brand_name, :brand_number,
      :generic_article_id, :number_type, :state, :packing_unit

    attr_accessor :scope

    # Find article by all number types and brand number and generic article id.
    # 
    # @option options [String] :article_number Article number will be converted within the search process to a simplified article number
    # @option options [Integer] :brand_no result of brand selection (optional)
    # @option options [String] :country country code according to ISO 3166
    # @option options [Integer] :generic_article_id result of generic article selection (optional)
    # @option options [String] :lang language code according to ISO 639
    # @option options [String] :number_type Number type (0: Article number, 1: OE number, 2: Trade number, 3: Comparable number, 4: Replacement number, 5: Replaced number, 6: EAN number, 10: Any number)
    # @option options [TrueClass, FalseClass] :search_exact Search mode (true: exact search, false: similar search)
    # @option options [Integer] :sort_type Sort mode (1: Brand, 2: Product group)
    # @return [Array<TecDoc::Article>] list of articles
    def self.search(options = {})
      options = {
        :country => TecDoc.client.country,
        :lang => I18n.locale.to_s,
        :number_type => 10,
        :search_exact => 1,
        :sort_type => 1
      }.merge(options)
      TecDoc.client.request(:get_article_direct_search_all_numbers2, options).map do |attributes|
        new(attributes, options)
      end
    end
    
    # All articles by linked vehicle and brand number, generic article and assembly group
    #
    # @option options [String] :lang
    # @option options [String] :country
    # @option options [String] :linking_target_type
    # @option options [Integer] :linking_target_id
    # @option options [LongList] :brand_id
    # @option options [LongList] :generic_article_id
    # @option options [Long] :article_assembly_group_node_id
    # @return [Array<TecDoc::Article>] list of articles
    def self.all(options)
      options = {
        :lang => I18n.locale.to_s,
        :country => TecDoc.client.country
      }.merge(options)
      TecDoc.client.request(:get_article_ids3, options).map do |attributes|
        new(attributes, options)
      end
    end
    
        
    # All requested articles detail information
    #
    # @option options [String]  :lang
    # @option options [String]  :country
    # @option options [Array]   :ids
    # @option options [Boolean] :attributs
    # @option options [Boolean] :ean_numbers
    # @option options [Boolean] :info
    # @option options [Boolean] :oe_numbers
    # @option options [Boolean] :usage_numbers
    # @return [Array<TecDoc::Article>] list of articles
    def self.all_with_details(options)
      options = {
        :lang => I18n.locale.to_s,
        :country => TecDoc.client.country,
        :attributs => true,
        :ean_numbers => true,
        :info => true,
        :oe_numbers => true,
        :usage_numbers => true,
        :article_id => { :array => { :ids => options.delete(:ids) } }
      }.merge(options)

      TecDoc.client.request(:get_direct_articles_by_ids2, options).map do |attributes|
        new(attributes, options)
      end
    end

    def initialize(attributes = {}, scope = {})
      article_data = (attributes[:direct_article] || attributes)
      
      @id                 = article_data[:article_id].to_i
      @name               = article_data[:article_name].to_s
      @number             = article_data[:article_no].to_s
      @brand_name         = article_data[:brand_name].to_s
      @brand_number       = article_data[:brand_no].to_i
      @generic_article_id = article_data[:generic_article_id].to_i
      @number_type        = article_data[:number_type].to_i
      @search_number      = article_data[:article_search_no].to_s
      @state              = article_data[:article_state_name]
      @scope              = scope

      @ean_number   = attributes[:ean_number].to_a.map(&:values).flatten.first
      @trade_number = attributes[:usage_numbers].to_a.map(&:values).flatten.first
      
      if attributes[:article_attributes]
        @attributes = attributes[:article_attributes].map do |attrs|
          ArticleAttribute.new(attrs)
        end
      end

      if attributes[:oen_numbers]
        @oe_numbers = attributes[:oen_numbers].map do |attrs|
          ArticleOENumber.new(attrs)
        end
      end
    end
    
    def state
      @state ||= (article_details[:direct_article] || {})[:article_state_name]
    end
    
    def packing_unit
      @packing_unit ||= (article_details[:direct_article] || {})[:packing_unit]
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
      @attributes ||= article_details[:article_attributes].map do |attrs|
        ArticleAttribute.new(attrs)
      end
    end

    def ean_number
      @ean_number ||= article_details[:ean_number].map(&:values).flatten.first
    end

    def oe_numbers
      @oe_numbers ||= article_details[:oen_numbers].map do |attrs|
        ArticleOENumber.new(attrs)
      end
    end
    
    def trade_numbers
      @trade_numbers ||= article_details[:usage_numbers].map(&:values).flatten.join(", ")
    end
    
    def information
      @information ||= direct_article_data_en[:article_info]
    end
    
    def linked_manufacturers
      unless @linked_manufacturers
        response = TecDoc.client.request(:get_article_linked_all_linking_target_manufacturer, {
          :country => scope[:country],
          :linking_target_type => "C",
          :article_id => id
        })
        
        @linked_manufacturers = response.map do |attrs|
          VehicleManufacturer.new(attrs)
        end
      end
      @linked_manufacturers
    end

    # Array with all linked target vehicles with article link id
    # If request entity is too large, we have to request linked targets by manufacturers
    def linked_targets
      unless @linked_targets
        options = {
          :lang => scope[:lang],
          :country => scope[:country],
          :linking_target_type => "C",
          :linking_target_id => -1,
          :article_id => id
        }
        begin
          @linked_targets = TecDoc.client.request(:get_article_linked_all_linking_target_2, options)
        rescue
          @linked_targets = linked_manufacturers.inject([]) do |result, manufacturer|
            options[:linking_target_manu_id] = manufacturer.id
            result += TecDoc.client.request(:get_article_linked_all_linking_target_2, options)
          end
        end
      end
      @linked_targets
    end
    
    def linked_vehicle_ids
      @linked_vehicle_ids ||= linked_targets.map{ |attrs| attrs[:linking_target_id].to_i }.uniq
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
            :motor_codes => true,
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
          vehicle.cylinder_capacity         = details[:cylinder_capacity_ccm].to_i
          vehicle.date_of_construction_from = DateParser.new(details[:year_of_construction_from]).to_date
          vehicle.date_of_construction_to   = DateParser.new(details[:year_of_construction_to]).to_date
          vehicle.motor_codes               = attrs[:motor_codes].map { |mc| mc[:motor_code] }
          vehicle
        end
      end
      @linked_vehicles
    end

    # Linked vehicles for article with car specific attributes
    def linked_vehicles_with_details(options = {})
      unless @linked_vehicles_with_details
        links = linked_targets.map do |link|
          new_link = link.dup
          new_link.delete(:linking_target_type)
          new_link
        end
        batch_list = links.each_slice(25).to_a
        
        # Response from all batches
        response = batch_list.inject([]) do |result, long_list|
          result += TecDoc.client.request(:get_article_linked_all_linking_targets_by_ids_2, {
            :linked_article_pairs => { :array => {:pairs => long_list} },
            :lang => scope[:lang],
            :country => scope[:country],
            :linking_target_type => "C",
            :immediate_attributs => true,
            :article_id => id
          })
          result
        end

        @linked_vehicles_with_details = response.map do |attrs|
          details = (attrs[:linked_vehicles].to_a[0] || {})
          vehicle                           = Vehicle.new
          vehicle.id                        = details[:car_id].to_i
          vehicle.name                      = "#{details[:manu_desc]} - #{details[:model_desc]} - #{details[:car_desc]}"
          vehicle.manu_id                   = details[:manu_id].to_i
          vehicle.mod_id                    = details[:model_id].to_i
          vehicle.power_hp_from             = details[:power_hp_from].to_i
          vehicle.power_kw_from             = details[:power_kw_from].to_i
          vehicle.power_hp_to               = details[:power_hp_to].to_i
          vehicle.power_kw_to               = details[:power_kw_to].to_i
          vehicle.cylinder_capacity         = details[:cylinder_capacity].to_i
          vehicle.date_of_construction_from = DateParser.new(details[:year_of_construction_from]).to_date
          vehicle.date_of_construction_to   = DateParser.new(details[:year_of_construction_to]).to_date
          vehicle.attributes                = attrs[:linked_article_immediate_attributs].to_a
          vehicle.article_link_id           = attrs[:article_link_id].to_i
          vehicle
        end
      end
      @linked_vehicles_with_details
    end

    private

    def article_details
      @article_details ||= TecDoc.client.request(:get_direct_articles_by_ids2, {
        :lang => scope[:lang],
        :country => scope[:country],
        :article_id => { :array => { :ids => [id] } },
        :attributs => true,
        :ean_numbers => true,
        :oe_numbers => true,
        :usage_numbers => true
      })[0]
    end
    
    # Direct article to get all detail info
    def direct_article_data_en
      @direct_article_data_en ||= TecDoc.client.request(:get_direct_articles_by_ids2, {
        :lang => "en",
        :country => TecDoc.client.country,
        :info => true,
        :article_id => { :array => { :ids => [id] } }
      })[0]
    end
  end
end
