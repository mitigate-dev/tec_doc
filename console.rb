$:.unshift File.dirname(__FILE__) + '/lib'

require "rubygems"
require "tec_doc"

I18n.locale = "lv"
TecDoc.client = TecDoc::Client.new(:provider => 330, :country => "lv")
