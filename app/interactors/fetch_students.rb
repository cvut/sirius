require 'interactors/kosapi_interactor'

class FetchStudents < KOSapiInteractor
  using Sequel::CoreRefinements

  def setup(*args)
    super
    @people = {}
  end

  def perform(faculty_semester:, future_events_only: true)
    client = kosapi_client(faculty_semester)

    @events = load_events(faculty_semester, future_events_only).map do |event|
      students = fetch_event_students(client, event)
      update_event_students(event, students)
      event
    end
  end

  def results
    { events: @events, people: @people.values }
  end

  def load_events(faculty_semester, future_only)
    query = Event.where(event_type: event_types, faculty: faculty_semester.faculty, semester: faculty_semester.code)
    query = query.where('starts_at > ?'.lit(Time.new)) if future_only
    query
  end

  def fetch_event_students(client, event)
    client.send(resource_name).find(event.source_id.to_i).limit(100).attendees
  end

  def update_event_students(event, students)
    student_ids = students.map do |student|
      @people[student.username] ||= Person.new(full_name: student.full_name) { |p| p.id = student.username }
      student.username
    end
    event.student_ids = student_ids
  end

  class << self
    attr_accessor :resource, :source_key, :event_types

    def [](resource, source_key:, event_types:)
      Class.new(self).tap do |cls|
        cls.resource = resource
        cls.source_key = source_key
        cls.event_types = event_types
      end
    end
  end

  def resource_name
    self.class.resource
  end

  def source_key
    self.class.source_key
  end

  def event_types
    self.class.event_types
  end
end
