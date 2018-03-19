module TecDoc
  class Brand
    attr_accessor :number, :name

    # Get all brands available for provider.
    #
    # @return [Array<TecDoc::Brand>] list of brands
    def self.all
      response = TecDoc.client.request(:getBrandsForAssortment) # TecDoc::Error: Unknown Call: getBrandsForAssortment
      response.map do |attributes|
        manufacturer = new
        manufacturer.number = attributes[:brand_no].to_i
        manufacturer.name = attributes[:brand_name].to_s
        manufacturer
      end
    end
  end
end