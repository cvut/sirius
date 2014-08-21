require 'interpipe/interactor'
require 'person'

class UpdateParallelStudents
  include Interpipe::Interactor

  def setup
    @students = {}
  end

  def perform(students:)
    students.each do |parallel, parallel_students|
      parallel.student_ids = process_students(parallel_students)
      parallel.save
    end
  end

  def process_students(students)
    students.map { |student| convert_student(student).id }
  end

  def convert_student(student)
    @students[student.username] ||= Person.new do |p|
      p.id = student.username
      p.full_name = student.full_name
    end
  end

  def results
    { people: @students.values }
  end

end
