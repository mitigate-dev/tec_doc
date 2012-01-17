module TecDoc
  class Language
    attr_accessor :code, :name

    # Get all languages available for provider.
    # 
    # @option options [String] :lang language code according to ISO 639
    # @return [Array<TecDoc::Language>] list of languages
    def self.all(options = {})
      options = {
        :lang => I18n.locale.to_s
      }.merge(options)
      response = TecDoc.client.request(:get_languages, options)
      response.map do |attributes|
        language = new
        language.code = attributes[:language_code].to_s
        language.name = attributes[:language_name].to_s
        language
      end
    end
  end
end
