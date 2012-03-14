require "spec_helper"

describe TecDoc::Client do
  it "should raise TecDoc::Error with status_text when the returned XML doesn't contains <status>200</status>" do
    lambda {
      VCR.use_cassette('status_401') do
        TecDoc.client.request(:get_pegasus_version_info)
      end
    }.should raise_error(TecDoc::Error, "Access not allowed")
  end
end
