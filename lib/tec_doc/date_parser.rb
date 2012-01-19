module TecDoc
  class DateParser
    def initialize(value)
      @value = value
    end

    def to_date
      if @value
        year, month = @value.to_i.divmod(100)
        Date.new(year, month, 1)
      end
    end
  end
end
