require 'kosapi_client'
require 'sirius/kosapi_client_registry'

module Sirius
  class UpdatedParallelsFinder

    def initialize(client: nil)
      @forced_client = client
    end

    def find_updated(page_size: 100, faculty: nil, semester: nil)
      query = build_query(faculty, semester)
      kosapi_client(faculty).parallels.where(query).limit(page_size)
    end

    private
    def build_query(faculty, semester)
      "(course.faculty=#{faculty});(semester=#{semester})"
    end

    def kosapi_client(faculty)
      @forced_client || KOSapiClientRegistry.instance.client_for_faculty(faculty)
    end

  end
end
