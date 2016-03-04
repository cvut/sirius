require 'interpipe/interactor'
require 'sequel/extensions/core_refinements'

class AssignPeople
  include Interpipe::Interactor
  using Sequel::CoreRefinements

  def perform(faculty_semester:, **options)
    exceptions = TeacherChangeScheduleException
      .where(faculty: faculty_semester.faculty, semester: faculty_semester.code).all

    exceptional_events = Event.where(:applied_schedule_exception_ids.pg_array.overlaps(
        Sequel.pg_array(exceptions.map(&:id), :bigint)))

    exceptional_event_ids = exceptional_events.map do |event|
      exceptions.each do |exception|
        exception.apply_people_assign(event) if exception.affects?(event)
      end
      event.id
    end

    assign_teachers! faculty_semester, exceptional_event_ids
    assign_students! faculty_semester
  end

  private

  def assign_teachers!(faculty_semester, skipped_event_ids)
    select_events_with_parallels(faculty_semester)
      .where(Sequel.~(events__id: skipped_event_ids))
      .where(Sequel.|(
        Sequel.~(events__teacher_ids: :parallels__teacher_ids),
        {events__teacher_ids: nil}
      ))
      .update(teacher_ids: :parallels__teacher_ids, updated_at: Sequel.function(:NOW))
  end

  def assign_students!(faculty_semester)
    select_events_with_parallels(faculty_semester)
      .where(Sequel.|(
        Sequel.~(events__student_ids: :parallels__student_ids),
        {events__student_ids: nil}
      ))
      .update(student_ids: :parallels__student_ids, updated_at: Sequel.function(:NOW))
  end

  def select_events_with_parallels(faculty_semester)
    DB[:events]
      .from(:events, :parallels)
      .where(parallel_id: :parallels__id)
      .where(events__faculty: faculty_semester.faculty, events__semester: faculty_semester.code)
  end
end
