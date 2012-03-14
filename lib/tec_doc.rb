require "i18n"
require "savon"

require "tec_doc/version"

module TecDoc
  extend self

  autoload :Client,               "tec_doc/client"
  autoload :Error,                "tec_doc/error"

  autoload :Article,              "tec_doc/article"
  autoload :ArticleDocument,      "tec_doc/article_document"
  autoload :ArticleThumbnail,     "tec_doc/article_thumbnail"
  autoload :ArticleOENumber,      "tec_doc/article_oe_number"
  autoload :ArticleAttribute,     "tec_doc/article_attribute"
  autoload :AssemblyGroup,        "tec_doc/assembly_group"
  autoload :Brand,                "tec_doc/brand"
  autoload :GenericArticle,       "tec_doc/generic_article"
  autoload :Language,             "tec_doc/language"
  autoload :VehicleManufacturer,  "tec_doc/vehicle_manufacturer"
  autoload :VehicleModel,         "tec_doc/vehicle_model"
  autoload :Vehicle,              "tec_doc/vehicle"

  autoload :DateParser,           "tec_doc/date_parser"

  attr_accessor :client
end

# Allow proxy with authentication
module HTTPI
  module Adapter
    class NetHTTP
      def new_client(request)
        proxy = request.proxy || URI("")
        Net::HTTP::Proxy(proxy.host, proxy.port, proxy.user, proxy.password).new request.url.host, request.url.port
      end
    end
  end
end
