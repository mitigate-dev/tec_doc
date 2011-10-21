module TecDoc
  class VehicleManufacturer
    attr_accessor :id, :name

    # Get all vehicle manufacturers
    # 
    # @option options [Integer] :car_type vehicle type (1: Passenger car, 2: Commercial vehicle, 3: Light commercial)
    # @option options [String] :countries_car_selection country code according to ISO 3166
    # @option options [TrueClass, FalseClass] :country_group_flag country group selection
    # @option options [TrueClass, FalseClass] :eval_favor simplified Flag: simplified vehicle selection
    # @option options [Integer, NilClass] :favoured_list simplified vehicle selection (1: first list selection, 0: rest) (optional)
    # @option options [String] :lang language code according to ISO 639
    # @return [Array<TecDoc::VehicleManufacturer>] list of languages
    def self.all(options)
      response = TecDoc.client.request(:get_vehicle_manufacturers3, options)
      response.to_hash[:get_vehicle_manufacturers3_response][:get_vehicle_manufacturers3_return][:data][:array][:array].map do |attributes|
        manufacturer = new
        manufacturer.id = attributes[:manu_id].to_i
        manufacturer.name = attributes[:manu_name].to_s
        manufacturer
      end
    end

    # Get all models that manufacturer has made
    # 
    # @param [Hash] options see `TecDoc::VehicleModel.all` for available options
    def models(options = {})
      VehicleModel.all(options.merge(:manu_id => id))
    end
  end
end
