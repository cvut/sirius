require 'active_support/core_ext/numeric/time'
require 'interpipe/interactor'

require 'roles/imported_exam'

class ConvertExams
  include Interpipe::Interactor

  def perform(exams:, faculty_semester:, **args)
    @exams = exams
    @faculty_semester = faculty_semester
    @events = exams.map { |exam| convert_exam(exam) }
  end

  def results
    { events: @events, exams: @exams }
  end

  def convert_exam(exam)
    ImportedExam.played_by(exam) do |exam|
      Event.new(
        starts_at: exam.start_date,
        ends_at: exam.end_date,
        course_id: exam.course.link_id,
        teacher_ids: [],
        capacity: exam.capacity,
        event_type: exam.event_type,
        source: Sequel.hstore({exam_id: exam.link.link_id}),
        semester: @faculty_semester.code,
        faculty: @faculty_semester.faculty
      ).tap do |event|
        event.room_id = exam.room.link_id if exam.room
        if exam.examiner
          event.teacher_ids = [exam.examiner.link_id]
        elsif exam.examiners
          event.teacher_ids = exam.examiners.map(&:link_id)
        end
        event.note = {cs: exam.note} if exam.note
      end
    end
  end

end
