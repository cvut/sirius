require 'api_spec_helper'

describe API::SampleEndpoint do
  include Rack::Test::Methods

  def app
    API::Base
  end

  context "the /foo endpoint" do
    before { get 'foo' }
    let(:response) { JSON.parse(last_response.body)}
    specify { response.should == {"foo" => "bar"}}
  end
end

