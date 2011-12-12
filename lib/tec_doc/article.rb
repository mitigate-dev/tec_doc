module TecDoc
  class Article
    attr_accessor :id, :name, :number, :search_number, :brand_name, :brand_number, :generic_article_id, :number_type

    # Find article by all number types and brand number and generic article id.
    # 
    # @option options [String] :article_number Article number will be converted within the search process to a simplified article number
    # @option options [Integer] :brand_no result of brand selection (optional)
    # @option options [String] :country country code according to ISO 3166
    # @option options [Integer] :generic_article_id result of generic article selection (optional)
    # @option options [String] :lang language code according to ISO 639
    # @option options [String] :number_type Number type (0: Article number, 1: OE number, 2: Trade number, 3: Comparable number, 4: Replacement number, 5: Replaced number, 6: EAN number, 10: Any number)
    # @option options [TrueClass, FalseClass] :search_exact Search mode (true: exact search, false: similar searc)
    # @option options [Integer] :sort_type Sort mode (1: Brand, 2: Product group)
    # @return [Array<TecDoc::Article>] list of articles
    def self.search(options = {})
      response = TecDoc.client.request(:get_article_direct_search_all_numbers2, options)
      response.map do |attributes|
        article = new
        article.id                 = attributes[:article_id].to_i
        article.name               = attributes[:article_name].to_s
        article.number             = attributes[:article_no].to_s
        article.brand_name         = attributes[:brand_name].to_s
        article.brand_number       = attributes[:brand_no].to_s
        article.generic_article_id = attributes[:generic_article_id].to_i
        article.number_type        = attributes[:number_type].to_i
        article.search_number      = attributes[:article_search_no].to_s
        article
      end
    end

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
