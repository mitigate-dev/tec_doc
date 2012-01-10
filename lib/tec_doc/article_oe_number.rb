module TecDoc
  class ArticleOENumber
    attr_accessor :block_number, :brand_name, :oe_number, :sort_number

    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end
  end
end
