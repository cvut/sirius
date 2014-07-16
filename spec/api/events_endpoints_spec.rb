require 'api_spec_helper'
require 'icalendar'

describe API::EventsEndpoints do
  subject { response }
  let!(:event) { Fabricate(:event) }
  let(:status) { response.status }
  let(:body) { response.body }
  let(:headers) { response.headers }

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

    context 'with default parameters' do
      before { get '/events' }

      it 'returns OK' do
        expect(status).to eql(200)
      end

      context 'JSON-API format' do
        subject { body }

        it { should have_json_size(1+2).at_path('events') }
      end

    end

    context 'with pagination' do
      before { get '/events?limit=2&offset=1'}
      subject { body }

      it { should have_json_size(2).at_path('events') }
    end

    context 'as an icalendar' do
      before { get '/events.ical' }

      it 'returns a valid content-type' do
        expect(headers['Content-Type']).to eql('text/calendar')
      end

      it 'returns a valid iCalendar' do
        calendar = Icalendar.parse(body).first
        expect(calendar.events.size).to eq 3
      end
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
