require 'api_spec_helper'

RSpec.shared_context 'authenticated user', authenticated: true do
  let(:username) { 'user' }
  let(:token) { Fabricate(:token, username: username) }
  let(:access_token) { { access_token: token.uuid } }

  def auth_get(path, **params)
    get path, params.merge(access_token)
  end
end

RSpec.shared_examples 'events endpoint' do
  include_context 'API response'

  include IcalendarHelper

  let(:path) { path_for super() } # assume path is given as a context from outside
  let(:events_cnt) { 3 }
  let(:events_params) { Hash.new }

  # Events from 2014-04-01 to 2014-04-03
  let!(:events) do
    i = 0
    Fabricate.times(events_cnt, :event, events_params) do
      starts_at { "2014-04-0#{i += 1} 14:30" } # XXX restart sequence for each fabrication
      ends_at { "2014-04-0#{i} 16:00" }
    end
  end
  let(:event) { events.first }

  let(:event_json) do
    {
      id: event.id,
      name: event.name,
      starts_at: event.starts_at,
      ends_at: event.ends_at,
      deleted: false,
      parallel: nil, # FIXME: could be stubbed
      event_type: 'lecture'
    }.to_json
  end

  # it 'is sane' do
  #   expect(Event.where(events_params).count).to eql events_cnt
  # end

  subject { body }


  context 'without access token' do
    before { get path }
    it 'returns 401 Unauthorized' do
      expect(status).to eql(401)
    end
  end

  context 'for authenticated user', authenticated: true do
    context 'with default parameters' do
      before { auth_get path }

      it 'returns OK' do
        expect(status).to eql(200)
      end

      it 'returns a JSON-API format' do
        expect(body).to have_json_size(events_cnt).at_path('events')
      end
    end

    context 'with pagination' do
      before { auth_get "#{path}?limit=1&offset=1" }
      let(:meta) do
        {
          limit: 1,
          offset: 1,
          count: events_cnt
        }
      end
      it { should have_json_size(1).at_path('events') }

      it { should be_json_eql(meta.to_json).at_path('meta') }

      context 'with offset 0 and default limit' do
        before { auth_get "#{path}?offset=0" }
        let(:meta) do
          {
            limit: FilterEvents::DEFAULT_LIMIT,
            offset: 0,
            count: events_cnt
          }
        end
        it { should have_json_size(events_cnt).at_path('events') }

        it { should be_json_eql(meta.to_json).at_path('meta') }
      end

      context 'with invalid value' do
        before { auth_get "#{path}?offset=asdasd" }
        it 'returns an error' do
          expect(response.status).to eql 400
        end

        context 'for invalid integer' do
          it 'returns an error for zero limit' do
            auth_get "#{path}?limit=0"
            expect(response.status).to eql 400
          end
          it 'returns an error for invalid (negative) offset' do
            auth_get "#{path}?offset=-1"
            expect(response.status).to eql 400
          end
        end
      end
    end

    context 'with date filtering' do
      before { auth_get "#{path}?from=2014-04-02T13:50&to=2014-04-03T00:00", access_token }
      it { should have_json_size(1).at_path('events') }

      context 'with invalid date' do
        before { auth_get "#{path}?from=asdasd", access_token }
        it 'returns an error' do
          expect(response.status).to eql 400
        end
      end
    end

    context 'with event type filtering' do
      context 'for event type lecture' do # lecture is a shared implicit type here; FIXME?
        before { auth_get "#{path}?event_type=lecture", access_token }
        it 'returns all lectures' do
          expect(body).to have_json_size(events_cnt).at_path('events')
        end
      end

      %w{laboratory exam tutorial}.each do |event_type|
        context "for alternate type of event #{event_type}" do
          before do
            event.update(event_type: event_type)
            auth_get "#{path}?event_type=#{event_type}", access_token
          end

          it 'returns at least one event' do
            expect(body).to have_json_size(1).at_path('events')
          end
        end
      end

      context 'with invalid value' do
        before { auth_get "#{path}?event_type=party", access_token }
        it 'returns an error' do
          expect(response.status).to eql 400
        end
      end

    end

    context 'as an icalendar' do
      before { auth_get "#{path}.ical", access_token }

      it 'returns a content-type with charset' do
        expect(headers['Content-Type']).to eql('text/calendar; charset=utf-8')
      end

      it 'returns a valid iCalendar' do
        calendar = parse_icalendar(body).first
        expect(calendar.events.size).to eq(events_cnt)
      end
    end
  end
end

RSpec.shared_examples 'invalid endpoint' do
  context 'for authenticated user', authenticated: true do
    it 'returns a Not Found error' do
      get path_for(path)
      expect(response.status).to eql 404
    end
  end
end

RSpec.shared_examples 'non-existent resource' do
  context 'for authenticated user', authenticated: true do
    before { auth_get path_for(path) }
    it 'returns a 404 Not Found error' do
      expect(status).to eql(404)
    end
    it 'returns a meaningful message' do
      expect(body).to be_json_eql('"Resource not found"').at_path('message')
    end
  end
end

RSpec.shared_examples 'forbidden resource' do
  context 'for authenticated user', authenticated: true do
    before { auth_get path_for(path) }
    it 'returns a 403 Frobidden error' do
      expect(status).to eql(403)
    end
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
      Fabricate(:event, capacity: 20) do
        teacher_ids ['vomackar']
        student_ids ['bubenpro']
        room { Fabricate(:room, kos_code: 'T9:350') }
        course { Fabricate(:course) }
        parallel { Fabricate(:parallel, code: 101 ) }
      end
    end
    let(:event_json) do
      {
        id: event.id,
        name: event.name,
        starts_at: event.starts_at,
        ends_at: event.ends_at,
        note: event.note,
        deleted: false,
        parallel: '101',
        capacity: 20,
        event_type: 'lecture',
        links: {
          room: event.room.to_s,
          course: event.course_id,
          students: event.student_ids,
          teachers: event.teacher_ids
        }
      }.to_json
    end
    it 'is not accessible without authentication' do
      get path_for("/events/#{event.id}")
      expect(status).to eql(401)
    end

    context 'for authenticated user', authenticated: true do
      context 'JSON-API format' do
        before { auth_get path_for("/events/#{event.id}") }
        subject { body }

        it 'returns OK' do
          expect(status).to eql(200)
        end
        it { should be_json_eql(event_json).at_path('events') }

      end

      it_behaves_like 'non-existent resource' do
        let(:path) { '/events/9001' }
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

      it_behaves_like 'non-existent resource' do
        let(:path) { "/rooms/YOLO/events" }
      end

      context 'with existing room' do
        it_behaves_like 'events endpoint' do
          let(:events_params) { { room: room } }
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

      it_behaves_like 'non-existent resource' do
        let(:path) { '/courses/MI-COB/events' } # Programming in Cobol is a not thing, yet?
      end

      context 'with existing course' do
        it_behaves_like 'events endpoint' do
          let(:events_params) { { course: course } }
        end
      end
    end
  end

  describe 'filter by person', authenticated: true do
    let(:username) { 'user' }
    let(:person) { Fabricate(:person, id: username) }
    let(:another_person) { Fabricate(:person, id: 'vomackar') }

    describe 'GET /people' do
      it_behaves_like 'invalid endpoint' do
        let(:path) { '/people' }
      end
    end

    describe 'GET /people/:username' do
      it_behaves_like 'invalid endpoint' do
        let(:path) { "/people/#{username}" }
      end
    end

    describe 'GET /people/:username/events' do
      let(:path) { "/people/#{username}/events" }

      context 'non-existent person' do
        it_behaves_like 'forbidden resource' do
          let(:path) { '/people/mranonym/events' }
        end
      end

      context 'authorized person within own scope' do
        it_behaves_like 'events endpoint' do
          let(:events_params) { { teacher_ids: [person.id] } }
        end
      end

      context 'authenticated person within scope for someone else' do
        it_behaves_like 'forbidden resource' do
          let(:path) { "/people/#{another_person.id}/events" }
        end
      end
    end
  end
end
