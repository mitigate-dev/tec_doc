$:.unshift File.dirname(__FILE__) + '/lib'

require "rubygems"
require "tec_doc"

TecDoc.client = TecDoc::Client.new(:provider => 330)
