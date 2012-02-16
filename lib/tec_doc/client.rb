module TecDoc
  class Client
    attr_accessor :provider, :country, :connection

    def initialize(options = {})
      self.provider = options[:provider]
      self.country  = options[:country]
      self.connection = Savon::Client.new do |wsdl, http|
        wsdl.document = File.expand_path("../wsdl.xml", __FILE__)
        proxy = options[:proxy] || ENV['http_proxy']
        http.proxy = proxy if proxy
      end
      self.mode = options[:mode] || :live
    end

    def request(operation, options = {})
      log operation, options do
        response = connection.request(operation) do
          soap.body = { :in => { :provider => provider }.merge(options) }
        end
        response.doc.xpath("//data/array/array").map do |node|
          node_to_hash(node)
        end
        # response
      end
    end

    def mode=(value)
      if value == :test
        connection.wsdl.endpoint = "http://webservicepilot.tecdoc.net/pegasus-2-0/services/TecdocToCatWL"
        @mode = :test
      else
        connection.wsdl.endpoint = "http://webservice-cs.tecdoc.net/pegasus-2-0/services/TecdocToCatWL"
        @mode = :live
      end
    end

    attr_reader :mode

    # Sets the logger to use.
    attr_writer :logger

    # Returns the logger. Defaults to an instance of +Logger+ writing to STDOUT.
    def logger
      @logger ||= ::Logger.new STDOUT
    end

    def log(operation, options)
      t = Time.now
      results = yield
      duration = 1000.0 * (Time.now - t)
      logger.info "TecDoc: #{operation.inspect} #{options.inspect} #{'(%.1fms)' % duration}"
      results
    end

    private

    def node_to_hash(node)
      attributes = {}
      node.children.each do |n|
        if n.xpath("empty").text == "true"
          attributes[n.name.snakecase.to_sym] = []
        elsif (n_array = n.xpath("array/array")).size > 0
          attributes[n.name.snakecase.to_sym] = n_array.map { |nn| node_to_hash(nn) }
        elsif n.children.reject { |nn| nn.is_a?(Nokogiri::XML::Text) }.size > 0
          attributes[n.name.snakecase.to_sym] = node_to_hash(n)
        elsif n.text == ""
          attributes[n.name.snakecase.to_sym] = nil
        else
          attributes[n.name.snakecase.to_sym] = n.text
        end
      end
      attributes
    end
  end
end
