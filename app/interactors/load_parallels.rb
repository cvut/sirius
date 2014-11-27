require 'interpipe/interactor'
require 'parallel'

class LoadParallels
  include Interpipe::Interactor

  def perform(faculty_semester:, **options)
    @results = { parallels: Parallel.where(faculty: faculty_semester.faculty, semester: faculty_semester.code).all, faculty_semester: faculty_semester }
  end

end
