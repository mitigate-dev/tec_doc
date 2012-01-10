module TecDoc
  class ArticleThumbnail < ArticleDocument
    # Find vehicle, axle, motor or universal assembly groups for the search tree
    # 
    # @option options [Integer] :article_id Article ID
    # @return [Array<TecDoc::ArticleThumbnail>] list of article thumbnails
    def self.all(options = {})
      response = TecDoc.client.request(:get_thumbnail_by_article_id, options)
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
