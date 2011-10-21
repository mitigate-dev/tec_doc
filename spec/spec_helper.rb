$:.unshift File.dirname(__FILE__) + '/../lib'

require "rubygems"
require "bundler/setup"
require "tec_doc"
require "vcr"

VCR.config do |c|
  c.cassette_library_dir = "spec/cassettes"
  c.stub_with :fakeweb
  c.ignore_localhost = true
  c.default_cassette_options = { :record => :new_episodes }
end

RSpec.configure do |config|
  config.extend VCR::RSpec::Macros
end

TecDoc.client = TecDoc::Client.new(:provider => 330)
