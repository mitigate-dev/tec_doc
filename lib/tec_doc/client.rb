module TecDoc
  class Client
    attr_accessor :provider, :connection

    def initialize(options = {})
      self.provider = options[:provider]
      self.connection = Savon::Client.new("http://webservicepilot.tecdoc.net/pegasus-2-0/wsdl/TecdocToCatWL")
    end

    def request(operation, options = {})
      response = connection.request(operation) do
        soap.body = { :in => { :provider => provider }.merge(options) }
      end
      response
    end
  end
end
