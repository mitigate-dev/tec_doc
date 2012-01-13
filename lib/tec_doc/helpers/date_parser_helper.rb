module Helpers
  module DateParserHelper
    def parse_tec_doc_date(date_to_parse)
      if date_to_parse
        year, month = date_to_parse.to_i.divmod(100)
        Date.new(year, month, 1)
      end
    end
  end
end