require 'api_spec_helper'
require 'icalendar'

RSpec.shared_examples 'events endpoint' do
  include_context 'API response'

  let(:path) { path_for super() } # assume path is given as a context from outside

  let(:events_cnt) { 3 }
  let(:events_params) { Hash.new }

  # Events from 2014-04-01 to 2014-04-03
  let!(:events) do
    i = 0
    Fabricate.times(events_cnt, :event, events_params) do
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

  # it 'is sane' do
  #   expect(Event.where(events_params).count).to eql events_cnt
  # end

  subject { body }

  context 'with default parameters' do
    before { get path }

    it 'returns OK' do
      expect(status).to eql(200)
    end

    it 'returns a JSON-API format' do
      expect(body).to have_json_size(events_cnt).at_path('events')
    end
  end

  context 'with pagination' do
    before { get "#{path}?limit=1&offset=1" }
    let(:meta) do
      {
        limit: 1,
        offset: 1,
        count: events_cnt
      }
    end
    it { should have_json_size(1).at_path('events') }

    it { should be_json_eql(meta.to_json).at_path('meta') }

    context 'with invalid value' do
      before { get "#{path}?offset=asdasd" }
      it 'returns an error' do
        expect(response.status).to eql 400
      end

      context 'for invalid integer'
      it 'returns an error' do
        pending 'needs a custom validator'
        get "#{path}?limit=-1"
        expect(response.status).to eql 400
      end
    end
  end

  context 'with date filtering' do
    before { get "#{path}?from=2014-04-02T13:50&to=2014-04-03T00:00" }
    it { should have_json_size(1).at_path('events') }

    context 'with invalid date' do
      before { get "#{path}?from=asdasd" }
      it 'returns an error' do
        expect(response.status).to eql 400
      end
    end
  end

  context 'as an icalendar' do
    before { get "#{path}.ical" }

    it 'returns a content-type with charset' do
      expect(headers['Content-Type']).to eql('text/calendar; charset=utf-8')
    end

    it 'returns a valid iCalendar' do
      calendar = Icalendar.parse(body).first
      expect(calendar.events.size).to eq(events_cnt)
    end
  end
end

RSpec.shared_examples 'invalid endpoint' do
  it 'returns a Not Found error' do
    get path_for(path)
    expect(response.status).to eql 404
  end
end


describe API::EventsEndpoints do
  include_context 'API response'

  describe 'GET /events' do
    let(:path) { '/events' }
    it_behaves_like 'events endpoint'
  end

  describe 'GET /events/:id' do
    let(:event) do
      Fabricate(:event) do
        teacher_ids ['vomackar']
        student_ids ['bubenpro']
        room { Fabricate(:room, kos_code: 'T9:350') }
        course { Fabricate(:course) }
      end
    end
    let(:event_json) do
      {
        id: event.id,
        name: event.name,
        starts_at: event.starts_at,
        ends_at: event.ends_at,
        note: event.note,
        links: {
          room: event.room.to_s,
          course: event.course_id,
          students: event.student_ids,
          teachers: event.teacher_ids
        }
      }.to_json
    end
    context 'JSON-API format' do
      before { get path_for("/events/#{event.id}") }
      subject { body }

      it 'returns OK' do
        expect(status).to eql(200)
      end
      it { should be_json_eql(event_json).at_path('events') }

    end

    context 'with non-existent resource' do
      before { get path_for('/events/9001') }
      it 'returns a Not Found error' do
        expect(status).to eql(404)
      end
    end
  end

  describe 'filter by rooms' do
    let(:room) { Fabricate(:room, kos_code: 'T9:350') }

    describe 'GET /rooms' do
      it_behaves_like 'invalid endpoint' do
        let(:path) { '/rooms' }
      end
    end

    describe 'GET /rooms/:kos_id' do
      it_behaves_like 'invalid endpoint' do
        let(:path) { "/rooms/#{room.kos_code}" }
      end
    end

    describe 'GET /rooms/:kos_code/events' do
      let(:path) { "/rooms/#{room.kos_code}/events" }

      context 'with non-existent room' do
        let(:path) { "/rooms/YOLO/events" }
        before { get path_for(path) }
        it 'returns a Not Found error' do
          expect(status).to eql 404
        end
      end

      context 'with existing room' do
        it_behaves_like 'events endpoint' do
          let(:events_params) { { room: room } }
        end
      end
    end
  end

  describe 'filter by person' do
    let(:person) { Fabricate(:person, id: 'vomackar') }

    describe 'GET /people' do
      it_behaves_like 'invalid endpoint' do
        let(:path) { '/people' }
      end
    end

    describe 'GET /people/:username' do
      it_behaves_like 'invalid endpoint' do
        let(:path) { "/people/#{person.id}" }
      end
    end

    describe 'GET /people/:username/events' do
      let(:path) { "/people/#{person.id}/events" }

      context 'with non-existent person' do
        let(:path) { "/people/mranonym/events" }
        before { get path_for(path) }
        it 'returns a Not Found error' do
          expect(status).to eql 404
        end
      end

      context 'with existing person' do
        it_behaves_like 'events endpoint' do
          let(:events_params) { { teacher_ids: [person.id] } }
        end
      end
    end
  end

  describe 'filter by course' do
    let(:course) { Fabricate(:course, id: 'MI-RUB') }

    describe 'GET /courses' do
      it_behaves_like 'invalid endpoint' do
        let(:path) { '/courses' }
      end
    end

    describe 'GET /courses/:course_id' do
      it_behaves_like 'invalid endpoint' do
        let(:path) { "/courses/#{course.id}" }
      end
    end

    describe 'GET /courses/:course_id/events' do
      let(:path) { "/courses/#{course.id}/events" }

      context 'with non-existent course' do
        before { get path_for(path) }
        let(:path) { "/courses/MI-COB/events" } # Programming in Cobol is a not thing, yet?
        it 'returns a Not Found error' do
          expect(status).to eql 404
        end
      end

      context 'with existing course' do
        it_behaves_like 'events endpoint' do
          let(:events_params) { { course: course } }
        end
      end
    end
  end
end
