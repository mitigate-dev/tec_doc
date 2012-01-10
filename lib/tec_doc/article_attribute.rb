module TecDoc
  class ArticleAttribute
    attr_accessor :block_no, :id, :is_conditional, :is_interval, :name, :short_name, :successor_id, :type, :unit, :value, :value_id

    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name.to_s.gsub(/^attr_/, '')}=", value)
      end
    end
  end
end
