require 'api_spec_helper'

describe API::EventsResource do
  subject { response }
  let(:event) { Fabricate(:event) }
  let(:status) { response.status }

  describe 'GET /events' do
    before { get '/events' }

    it 'returns a collection of events' do
      expect(status).to eql(200)
    end
  end

  describe 'GET /events/:id' do
    before { get "/events/#{event.id}", format: :json }

    it 'returns an event' do
      expect(status).to eql(200)
    end
  end
end
