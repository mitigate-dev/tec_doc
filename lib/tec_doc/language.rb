module TecDoc
  class Language
    attr_accessor :code, :name

    # Get all languages available for provider.
    # 
    # @option options [String] :lang The language in which you want to get the results
    # @return [Array<TecDoc::Language>] list of languages
    def self.all(options = {})
      response = TecDoc.client.request(:get_languages, options)
      response.to_hash[:get_languages_response][:get_languages_return][:data][:array][:array].map do |attributes|
        language = new
        language.code = attributes[:language_code].to_s
        language.name = attributes[:language_name].to_s
        language
      end
    end
  end
end
