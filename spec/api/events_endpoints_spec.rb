require 'api_spec_helper'

describe API::EventsEndpoints do
  subject { response }
  let!(:event) { Fabricate(:event) }
  let(:status) { response.status }
  let(:body) { response.body }

  let(:event_json) do
    {
      id: event.id,
      name: event.name,
      starts_at: event.starts_at,
      ends_at: event.ends_at
    }.to_json
  end

  describe 'GET /events' do
    let!(:events) { Fabricate.times(2, :event) }
    before { get '/events' }

    it 'returns OK' do
      expect(status).to eql(200)
    end

    context 'JSON-API format' do
      subject { body }

      it { should have_json_size(1+2).at_path('events') }

    end
  end

  describe 'GET /events/:id' do
    context 'JSON-API format' do
      before { get "/events/#{event.id}" }
      subject { body }

      it 'returns OK' do
        expect(status).to eql(200)
      end

      it { should have_json_size(1).at_path('events') }

      it { should be_json_eql(event_json).at_path('events/0') }

    end
  end
end
