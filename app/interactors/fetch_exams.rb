require 'interactors/kosapi_interactor'

class FetchExams < KOSapiInteractor

  def perform(faculty_semester:)
    @faculty_semester = faculty_semester
    client = kosapi_client(faculty_semester)
    @exams = client.exams.where("course.faculty==#{faculty_semester.faculty};semester=#{faculty_semester.code}").limit(100)
  end

  def results
    { exams: @exams, faculty_semester: @faculty_semester }
  end

end
