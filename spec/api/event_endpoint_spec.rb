require 'spec_helper'

describe Sirius::EventEndpoint do
  subject { response }
  let(:status) { response.status }
  let :event_attributes do
    {
      name: 'Test event',
      starts_at: '2014-04-23T07:30:00Z',
      ends_at: '2014-04-23T09:00:00Z'
    }
  end

  describe 'GET /events' do
    before { get '/events' }

    it 'returns a collection of events' do
      expect(status).to eql 200
    end
  end

  describe 'POST /events' do
    before { post '/events', event_attributes, format: :json }

    it 'creates an event' do
      expect(status).to eql 201
    end

    context 'with invalid data' do
      let(:event_attributes) do
        { name: 'Invalid' }
      end

      it 'returns an error' do
        expect(status).to eql 422
      end
    end


  end
end
