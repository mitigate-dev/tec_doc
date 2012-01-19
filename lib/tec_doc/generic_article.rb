module TecDoc
  class GenericArticle
    attr_accessor :id, :name
    attr_accessor :scope
    
    # getGenericArticlesByManufacturer5()
    
    # Get generic articles
    #
    # @option options [Integer] :assembly_group_node_id (optional)
    # @option options [LongList] :generic_article_id (optional)
    # @option options [LongList] :brand_no result of brand selection (optional)
    # @option options [String] :linking_target_type - "C", "M", "A", "K", "U"
    # @option options [Integer] :linking_target_id - null if "U"
    # @option options [Integer] :result_mode - 1: Distinct brand numbers, 2: Distinct generic articles, 3: Both (optional)
    # @option options [Integer] :sort_mode - 1: Brand name, 2: Article norm name (optional)
    # @return [Array<TecDoc::GenericArticle>] list of generic articles
    def self.all(options = {})
      options = {
        :lang => I18n.locale.to_s,
        :country => TecDoc.client.country
      }.merge(options)
      TecDoc.client.request(:get_generic_articles_by_manufacturer6, options).map do |attributes|
        new(attributes, options)
      end
    end
    
    def initialize(attributes = {}, scope = {})
      @id    = (attributes[:id] || attributes[:generic_article_id])
      @name  = attributes[:article_norm_name]
      @scope = scope
    end

    # Generic article linked articles
    def articles(options = {})
      options = {
        :linking_target_type => scope[:linking_target_type],
        :linking_target_id   => scope[:linking_target_id]
      }.merge(options).merge({
        :generic_article_id => { :array => { :id => [id] } }
      })
      Article.all(options)
    end
  end
end
