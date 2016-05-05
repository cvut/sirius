require 'celluloid'
require 'actors/etl_consumer'
require 'event'

class TeacherTimetablesCleaner
  include Celluloid
  include ETLConsumer

  def initialize(input, parent_actor, faculty_semester)
    set_input(input)
    @parent_actor = parent_actor
    @seen_event_ids = Set.new
    @faculty_semester = faculty_semester
  end

  def process_row(saved_events)
    @seen_event_ids = @seen_event_ids + saved_events.map(&:id)
    notify_hungry
  end

  def process_eof
    mark_unseen_events(@faculty_semester, @seen_event_ids)
    Celluloid::Actor[@parent_actor].async.receive_eof
  end

  def mark_unseen_events(faculty_semester, seen_event_ids)
    Event.where(
      faculty: faculty_semester.faculty,
      semester: faculty_semester.code,
      deleted: false,
      event_type: 'teacher_timetable'
    ).exclude(id: seen_event_ids.to_a)
    .update(deleted: true, updated_at: Sequel.function(:NOW))
  end
end
