require 'interpipe/interactor'

class AssignPeople
  include Interpipe::Interactor

  def perform(faculty_semester:, **options)
    DB[:events].from(:events, :parallels)
    .where(parallel_id: :parallels__id, events__faculty: faculty_semester.faculty, events__semester: faculty_semester.code)
    .update(student_ids: :parallels__student_ids, teacher_ids: :parallels__teacher_ids)
  end

end
