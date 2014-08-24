require 'interpipe/interactor'
require 'kosapi_client'

class FetchParallelStudents
  include Interpipe::Interactor

  def setup(client: KOSapiClient.client)
    @client = client
  end

  def perform(parallels:, **options)
    students = parallels.map do |parallel|
      [parallel, fetch_students(parallel)]
    end
    @students = Hash[students]
  end

  def results
    {students: @students}
  end

  def fetch_students(parallel)
    @client.parallels.find(parallel.id).students.limit(100).offset(0)
  end

end
