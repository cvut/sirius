require 'interpipe/interactor'
require 'kosapi_client'
require 'sirius/kosapi_client_registry'

class FetchParallelStudents
  include Interpipe::Interactor

  def setup(client: nil)
    @forced_client = client
  end

  def perform(parallels:, faculty_semester:, **options)
    client = kosapi_client(faculty_semester)
    students = parallels.map do |parallel|
      [parallel, fetch_students(parallel, client)]
    end
    @students = Hash[students]
  end

  def results
    {students: @students}
  end

  def fetch_students(parallel, client)
    client.parallels.find(parallel.id).students.limit(100).offset(0)
  end

  private
  def kosapi_client(faculty_semester)
    @forced_client || Sirius::KOSapiClientRegistry.instance.client_for_faculty(faculty_semester.faculty)
  end

end
