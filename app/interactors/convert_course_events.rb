require 'interpipe/interactor'

class ConvertCourseEvents
  include Interpipe::Interactor

  def perform(course_events:, faculty_semester:)
    @course_events = course_events
    @faculty_semester = faculty_semester
    @events = course_events.map { |event| convert_event(event) }
  end

  def results
    { events: @events, course_events: @course_events }
  end

  def convert_event(course_event)
    Event.new(
      starts_at: course_event.start_date,
      ends_at: course_event.end_date,
      capacity: course_event.capacity,
      event_type: 'course_event',
      source: Sequel.hstore({course_event_id: course_event.link.link_id}),
      semester: @faculty_semester.code,
      faculty: @faculty_semester.faculty,
      room_id: course_event.room.try(:link_id),
      teacher_ids: [course_event.creator.try(:link_id)].compact,
      name: course_event.name.try(:translations),
      note: course_event.note.try(:translations),
      course_id: course_event.course.try(:link_id)
    )
  end

end
