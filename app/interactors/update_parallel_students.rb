require 'interpipe/interactor'
require 'person'

class UpdateParallelStudents
  include Interpipe::Interactor

  def setup
    @students = {}
  end

  def perform(students:)
    students.each do |parallel, parallel_students|
      student_ids = process_students(parallel_students)
      if parallel.student_ids != student_ids
        parallel.student_ids = student_ids
        parallel.this.update(student_ids: Sequel.pg_array(student_ids, :text), updated_at: Sequel.function(:NOW))
      end
    end
  end

  def process_students(students)
    students.map { |student| convert_student(student).id }
  end

  def convert_student(student)
    student_id = get_student_id(student)
    @students[student_id] ||= Person.new do |p|
      p.id = student_id
      p.full_name = student.full_name
    end
  end

  def results
    { people: @students.values }
  end

  def get_student_id(student)
    student.username || student.personal_number
  end

end
