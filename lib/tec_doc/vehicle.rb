module TecDoc
  class Vehicle
    attr_accessor \
      :id,
      :name,
      :cylinder_capacity,
      :fuel_type,
      :fuel_type_process,
      :first_country,
      :linked,
      :power_hp_from,
      :power_hp_to,
      :power_kw_from,
      :power_kw_to,
      :date_of_construction_from,
      :date_of_construction_to,
      :motor_codes,
      :manu_id,
      :mod_id,
      :attributes,
      :article_link_id

    # Find vehicles for simplified selection with motor codes
    #
    # @option options [Integer] :car_type vehicle type (1: Passenger car, 2: Commercial vehicle, 3: Light commercial)
    # @option options [String] :countries_car_selection country code according to ISO 3166
    # @option options [TrueClass, FalseClass] :country_group_flag country group selection
    # @option options [String] :country_user_setting country for article assignments, country code according to assignments ISO 3166 (optional)
    # @option options [Integer, NilClass] :favoured_list simplified vehicle selection (1: first list selection, 0: rest)
    # @option options [String] :lang language code according to ISO 639
    # @option options [TrueClass, FalseClass] :linked selection with/without article assignments (false: all, true: only linked articles)
    # @option options [Integer] :manu_id manufacturer ID
    # @option options [Integer] :mod_id vehicle ID
    # @return [Array<TecDoc::VehicleManufacturer>] list of vehicles with motor codes
    def self.all(options = {})
      options = {
        :car_type => 1,
        :countries_car_selection => TecDoc.client.country,
        :country_group_flag => false,
        :favoured_list => 1,
        :lang => I18n.locale.to_s,
        :linked => false
      }.merge(options)
      response = TecDoc.client.request(:get_vehicle_simplified_selection4, options)
      response.map do |attributes|
        vehicle = new
        car_attributes = attributes[:car_details]
        if car_attributes
          vehicle.manu_id                   = options[:manu_id].to_i
          vehicle.mod_id                    = options[:mod_id].to_i
          vehicle.id                        = car_attributes[:car_id].to_i
          vehicle.name                      = car_attributes[:car_name].to_s
          vehicle.cylinder_capacity         = car_attributes[:cylinder_capacity].to_i
          vehicle.first_country             = car_attributes[:first_country].to_s
          vehicle.linked                    = car_attributes[:linked]
          vehicle.power_hp_from             = car_attributes[:power_hp_from].to_i
          vehicle.power_hp_to               = car_attributes[:power_hp_to].to_i
          vehicle.power_kw_from             = car_attributes[:power_kw_from].to_i
          vehicle.power_kw_to               = car_attributes[:power_kw_to].to_i
          vehicle.date_of_construction_from = DateParser.new(car_attributes[:year_of_constr_from]).to_date
          vehicle.date_of_construction_to   = DateParser.new(car_attributes[:year_of_constr_to]).to_date
        end
        vehicle.motor_codes = attributes[:motor_codes].map { |mc| mc[:motor_code] }
        vehicle
      end
    end
    
    def self.find(options = {})
      id = options.delete(:id)
      options = {
        :car_ids => { :array => { :ids => [id] } },
        :countries_car_selection => TecDoc.client.country,
        :country_user_setting => TecDoc.client.country,
        :country => TecDoc.client.country,
        :lang => TecDoc.client.country,
        :axles => false,
        :cabs => false,
        :country_group_flag => false,
        :motor_codes => true,
        :vehicle_details_2 => false,
        :vehicle_terms => true
      }.merge(options)
      response = TecDoc.client.request(:get_vehicle_by_ids_2, options)
      if attrs = response.first
        details   = attrs[:vehicle_details]  || {}
        details2  = attrs[:vehicle_details2] || {}
        terms     = attrs[:vehicle_terms]    || {}
        vehicle  = new
        vehicle.id                        = attrs[:car_id].to_i
        vehicle.name                      = terms[:car_type].to_s
        vehicle.cylinder_capacity         = details[:ccm_tech].to_i
        vehicle.fuel_type                 = details2[:fuel_type].to_s
        vehicle.fuel_type_process         = details2[:fuel_type_process].to_s
        vehicle.power_hp_from             = details[:power_hp_from].to_i
        vehicle.power_hp_to               = details[:power_hp_to].to_i
        vehicle.power_kw_from             = details[:power_kw_from].to_i
        vehicle.power_kw_to               = details[:power_kw_to].to_i
        vehicle.date_of_construction_from = DateParser.new(details[:year_of_constr_from]).to_date
        vehicle.date_of_construction_to   = DateParser.new(details[:year_of_constr_to]).to_date
        vehicle.manu_id                   = details[:manu_id].to_i
        vehicle.mod_id                    = details[:mod_id].to_i
        vehicle.motor_codes = attrs[:motor_codes].map { |mc| mc[:motor_code] }
        vehicle
      else
        nil
      end
    end

    def attributes
      @attributes || []
    end

    def attributes=(attrs)
      @attributes = attrs.map{ |attr| ArticleAttribute.new(attr) }
    end
    
    # Vehicle linked assembly parent groups
    def assembly_groups(options = {})
      options.merge!({
        :linking_target_type => "C",
        :linking_target_id => id,
      })
      AssemblyGroup.all(options)
    end
  end
end