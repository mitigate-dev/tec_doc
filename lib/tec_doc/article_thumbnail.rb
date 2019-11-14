module TecDoc
  class ArticleThumbnail < ArticleDocument
    # Find article thumbnail documents
    #
    # @option options [Integer] :article_id Article ID
    # @return [Array<TecDoc::ArticleThumbnail>] list of article thumbnails
    def self.all(options = {})
      response = TecDoc.client.request(:getThumbnailByArticleId, options) # Unknown call (removed?)
      response.map do |attributes|
        thumbnail = new
        thumbnail.id        = attributes[:thumb_doc_id].to_i
        thumbnail.file_name = attributes[:thumb_file_name].to_s
        thumbnail.type_id   = attributes[:thumb_type_id].to_i
        thumbnail
      end
    end
  end
end
