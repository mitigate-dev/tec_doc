module TecDoc
  class ArticleAttribute
    attr_accessor :block_no, :id, :is_conditional, :is_interval, :is_linked, :name, :short_name, :successor_id, :type, :unit, :value, :value_id

    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name.to_s.gsub(/^attr_/, '')}=", value)
      end

      @id             = @id.to_i                       if @id
      @value_id       = @value_id.to_i                 if @value_id
      @value          = DateParser.new(@value).to_date if @type == "D"
      @is_interval    = (@is_interval == "true")       if @is_interval.is_a?(String)
      @is_conditional = (@is_conditional == "true")    if @is_conditional.is_a?(String)
    end
  end
end
