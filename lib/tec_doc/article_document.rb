module TecDoc
  class ArticleDocument
    attr_accessor :id, :file_name, :file_type_name, :link_id, :description, :type_id, :type_name

    # getArticleDocuments()

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
