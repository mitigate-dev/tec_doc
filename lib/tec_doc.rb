require "savon"

require "tec_doc/version"

module TecDoc
  extend self

  autoload :Client,       "tec_doc/client"

  autoload :Brand,        "tec_doc/brand"
  autoload :Language,     "tec_doc/language"

  attr_accessor :client
end
