require 'interpipe/interactor'
require 'sequel/extensions/core_refinements'

class AssignPeople
  include Interpipe::Interactor
  using Sequel::CoreRefinements

  def perform(faculty_semester:, **options)
    exceptions = TeacherChangeScheduleException.where(faculty: faculty_semester.faculty, semester: faculty_semester.code).all
    exception_ids = Sequel.pg_array(exceptions.map(&:id), :bigint)
    exceptional_event_ids = Event.where(:applied_schedule_exception_ids.pg_array.overlaps(exception_ids)).map do |event|
      exceptions.each do |exception|
        exception.apply_people_assign(event) if exception.affects?(event)
      end
      event.id
    end
    assign_regular(faculty_semester, exceptional_event_ids)
  end

  private

  def assign_regular(faculty_semester, skipped_event_ids)
    DB[:events].from(:events, :parallels)
    .where(parallel_id: :parallels__id, events__faculty: faculty_semester.faculty, events__semester: faculty_semester.code)
    .where(Sequel.~(events__id: skipped_event_ids))
    .where(Sequel.|(
      Sequel.~(events__student_ids: :parallels__student_ids, events__teacher_ids: :parallels__teacher_ids),
      {events__student_ids: nil},
      {events__teacher_ids: nil}
    ))
    .update(student_ids: :parallels__student_ids, teacher_ids: :parallels__teacher_ids, updated_at: Sequel.function(:NOW))
  end

end
