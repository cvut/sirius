require 'api_spec_helper'
require 'icalendar'

describe API::EventsEndpoints do
  subject { response }
  let(:status) { response.status }
  let(:body) { response.body }
  let(:headers) { response.headers }

  let(:events_cnt) { 3 }
  let(:events) do
    i = 1
    Fabricate.times(events_cnt, :event) do
      starts_at { "2014-04-0#{i+=1} 14:30" } # XXX sequencer in times doesn't work
      ends_at { "2014-04-0#{i} 16:00" }
    end
  end
  let(:event) { events.first }

  let(:event_json) do
    {
      id: event.id,
      name: event.name,
      starts_at: event.starts_at,
      ends_at: event.ends_at
    }.to_json
  end

  describe 'GET /events' do
    before { events }

    context 'with default parameters' do
      before { get '/events' }

      it 'returns OK' do
        expect(status).to eql(200)
      end

      context 'JSON-API format' do
        subject { body }

        it { should have_json_size(events_cnt).at_path('events') }
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
        expect(calendar.events.size).to eq(events_cnt)
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
