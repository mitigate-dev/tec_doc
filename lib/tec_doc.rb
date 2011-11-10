require "savon"

require "tec_doc/version"

module TecDoc
  extend self

  autoload :Client,               "tec_doc/client"

  autoload :Article,              "tec_doc/article"
  autoload :AssemblyGroup,        "tec_doc/assembly_group"
  autoload :Brand,                "tec_doc/brand"
  autoload :Language,             "tec_doc/language"
  autoload :VehicleManufacturer,  "tec_doc/vehicle_manufacturer"
  autoload :VehicleModel,         "tec_doc/vehicle_model"
  autoload :Vehicle,              "tec_doc/vehicle"

  attr_accessor :client
end
