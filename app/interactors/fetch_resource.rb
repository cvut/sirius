require 'interactors/kosapi_interactor'
require 'sirius/faculty_semester_query'

class FetchResource < KOSapiInteractor

  def perform(faculty_semester:, limit: 100, paginate: true)
    @faculty_semester = faculty_semester
    client = kosapi_client(faculty_semester)
    resource = client.send(resource_name)
    @data = query_instance.apply(resource, faculty_semester: faculty_semester).limit(limit)
    @data.auto_paginate = paginate
  end

  def results
    { resource_name => @data, faculty_semester: @faculty_semester }
  end

  class << self
    attr_accessor :resource, :query_instance

    def [](resource, query_instance: FacultySemesterQuery.new)
      Class.new(self).tap do |cls|
        cls.resource = resource
        cls.query_instance = query_instance
      end
    end
  end

  def resource_name
    self.class.resource
  end

  def query_instance
    self.class.query_instance
  end

end
