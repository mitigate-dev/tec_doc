module TecDoc
  class ArticleDocument
    attr_accessor :id, :file_name, :file_type_name, :link_id, :description, :type_id, :type_name

    # Find document descriptions to an article
    #
    # @option options [Integer] :article_id article ID
    # @option options [Integer] :article_link_id article link ID (optional)
    # @option options [String] :country country code according to ISO 3166
    # @option options [Integer] :doc_type_id document type (KT 141) (optional)
    # @option options [String] :lang language code according to ISO 639
    # @return [Array<TecDoc::ArticleDocument>] list of article documents
    def self.all(options = {})
      options = {
        :country => TecDoc.client.country,
        :lang => I18n.locale.to_s
      }.merge(options)
      response = TecDoc.client.request(:get_article_documents, options)
      response.map do |attributes|
        document = new
        document.id             = attributes[:doc_id].to_i
        document.link_id        = attributes[:doc_link_id].to_i
        document.file_name      = attributes[:doc_file_name].to_s
        document.file_type_name = attributes[:doc_file_type_name].to_s
        document.type_id        = attributes[:doc_type_id].to_i
        document.type_name      = attributes[:doc_type_name].to_s
        document
      end
    end

    def url
      base_url = TecDoc.client.connection.wsdl.document.gsub("/wsdl/TecdocToCatWL", "")
      provider = TecDoc.client.provider
      thumbnail_flag = self.is_a?(ArticleThumbnail) ? "1" : "0"
      "#{base_url}/documents/#{provider}/#{id}/#{thumbnail_flag}"
    end

    def content
      request = TecDoc.client.connection.http
      request.url = url
      request.body = nil
      request.headers = {}
      response = HTTPI.post(request)
      response.raw_body
    end
  end
end
