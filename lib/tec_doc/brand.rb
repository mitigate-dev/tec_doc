module TecDoc
  class Brand
    attr_accessor :number, :name

    # Get all brands available for provider.
    # 
    # @return [Array<TecDoc::Brand>] list of brands
    def self.all
      response = TecDoc.client.request(:get_brands_for_assortment)
      response.to_hash[:get_brands_for_assortment_response][:get_brands_for_assortment_return][:data][:array][:array].map do |attributes|
        manufacturer = new
        manufacturer.number = attributes[:brand_no].to_s
        manufacturer.name = attributes[:brand_name].to_s
        manufacturer
      end
    end
  end
end