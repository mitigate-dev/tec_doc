require "tec_doc/helpers/date_parser_helper"

module TecDoc
  class Vehicle
    extend Helpers::DateParserHelper
    
    attr_accessor \
      :id,
      :name,
      :cylinder_capacity,
      :first_country,
      :linked,
      :power_hp_from,
      :power_hp_to,
      :power_kw_from,
      :power_kw_to,
      :date_of_construction_from,
      :date_of_construction_to,
      :motor_codes

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
          vehicle.id                        = car_attributes[:car_id].to_i
          vehicle.name                      = car_attributes[:car_name].to_s
          vehicle.cylinder_capacity         = car_attributes[:cylinder_capacity].to_i
          vehicle.first_country             = car_attributes[:first_country].to_s
          vehicle.linked                    = car_attributes[:linked]
          vehicle.power_hp_from             = car_attributes[:power_hp_from].to_i
          vehicle.power_hp_to               = car_attributes[:power_hp_to].to_i
          vehicle.power_kw_from             = car_attributes[:power_kw_from].to_i
          vehicle.power_kw_to               = car_attributes[:power_kw_to].to_i
          vehicle.date_of_construction_from = parse_tec_doc_date car_attributes[:year_of_constr_from]
          vehicle.date_of_construction_to   = parse_tec_doc_date car_attributes[:year_of_constr_to]
        end
        vehicle.motor_codes = attributes[:motor_codes].map { |mc| mc[:motor_code] }
        vehicle
      end
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