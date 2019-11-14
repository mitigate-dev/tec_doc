module TecDoc
  class Client
    attr_accessor :provider, :country, :connection

    def initialize(options = {})
      self.provider = options[:provider]
      self.country  = options[:country]
      self.connection = Savon::Client.new do |wsdl, http|
        proxy = options[:proxy] || ENV['http_proxy']
        http.proxy = proxy if proxy
      end
      self.mode = options[:mode] || :live
    end

    def request(operation, options = {})
      log operation, options do
        response = connection.request(operation) do
          soap.body = { :provider => provider }.merge(options)
        end
        # Parse errors
        status_node = response.doc.xpath("//status").first
        if status_node.text != "200"
          status_text_node = response.doc.xpath("//statusText").first
          raise Error.new(status_text_node.text)
        end
        # Parse the document
        response.doc.xpath("//data/array").map do |node|
          node_to_hash(node)
        end
        # response
      end
    end

    def mode=(value)
      if value == :test
        connection.wsdl.endpoint = "http://webservicepilot.tecdoc.net:80/pegasus-3-0/services/TecdocToCatDLB.soapEndpoint"
        connection.wsdl.namespace = connection.wsdl.endpoint
        @mode = :test
      else
        connection.wsdl.endpoint = "https://webservice.tecalliance.services/pegasus-3-0/services/TecdocToCatDLB.soapEndpoint"
        connection.wsdl.namespace = connection.wsdl.endpoint
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
        elsif (n_array = n.xpath("array")).size > 0
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
