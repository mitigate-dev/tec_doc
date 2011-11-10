module TecDoc
  class Article
    attr_accessor :id, :name, :number, :search_number, :brand_name, :brand_number, :generic_article_id, :number_type

    # Find article by all number types and brand number and generic article id.
    # def self.search(options = {})
    #   TecDoc.client.request(:get_article_direct_search_all_numbers2, {
    #     :article_number => "31966",
    #     :number_type => 10,
    #     :lang => "lv",
    #     :country => "lv",
    #     :sort_type => 1,
    #     :search_exact => false,
    #     :brandno => nil,
    #     :generic_article_id => nil
    #   })
    # end

    def brand
      unless defined?(@brand)
        @brand = Brand.new
        @brand.number = brand_number
        @brand.name = brand_name
      end
      @brand
    end
  end
end
