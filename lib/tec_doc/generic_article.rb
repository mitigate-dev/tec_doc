module TecDoc
  class GenericArticle
    attr_accessor :id
    
    # getGenericArticlesByManufacturer5()
    # getGenericArticlesByManufacturer6()
    
    def initialize(attributes = {})
      @id = attributes[:id]
    end
    
    # Generic article linked articles
    def articles(options = {})
      options.merge!({
        :generic_article_id => { :array => { :id => [id] } }
      })
      Article.all(options)
    end
  end
end
