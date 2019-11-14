module TecDoc
  class Brand
    attr_accessor :number, :name

    # Get all brands available for provider.
    #
    # @return [Array<TecDoc::Brand>] list of brands
    def self.all
      options = {
        :lang => TecDoc.client.country,
        :article_country => TecDoc.client.country
      }
      response = TecDoc.client.request(:getAmBrands, options)
      response.map do |attributes|
        manufacturer = new
        manufacturer.number = attributes[:brand_id].to_i
        manufacturer.name = attributes[:brand_name].to_s
        manufacturer
      end
    end
  end
end
