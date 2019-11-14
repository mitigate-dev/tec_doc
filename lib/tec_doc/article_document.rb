module TecDoc
  class ArticleDocument
    BASE_URL = "http://webservice.tecalliance.services/pegasus-3-0".freeze

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
        :article_country => TecDoc.client.country,
        :lang => I18n.locale.to_s,
        :documents => true
      }.merge(options)
      response = TecDoc.client.request(:getDirectArticlesByIds6, options).first
      response[:article_documents].to_a.map do |attributes|
        new attributes
      end
    end

    def initialize(attributes = {})
      @id             = attributes[:doc_id].to_i
      @link_id        = attributes[:doc_link_id].to_i
      @file_name      = attributes[:doc_file_name].to_s
      @file_type_name = attributes[:doc_file_type_name].to_s
      @type_id        = attributes[:doc_type_id].to_i
      @type_name      = attributes[:doc_type_name].to_s
    end

    def url
      provider = TecDoc.client.provider
      thumbnail_flag = self.is_a?(ArticleThumbnail) ? "1" : "0"
      "#{BASE_URL}/documents/#{provider}/#{id}/#{thumbnail_flag}"
    end

    def content
      HTTPI.get(url).raw_body
    end
  end
end
