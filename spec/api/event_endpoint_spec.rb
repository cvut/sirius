require 'spec_helper'

describe Sirius::EventEndpoint do
  it 'returns all events' do
    get '/events'
    expect(response.status).to eql 200
  end
end
