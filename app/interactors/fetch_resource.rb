require 'interactors/kosapi_interactor'

class FetchResource < KOSapiInteractor

  def perform(faculty_semester:, limit: 100, paginate: true)
    @faculty_semester = faculty_semester
    client = kosapi_client(faculty_semester)
    @data = client.send(resource).where("course.faculty==#{faculty_semester.faculty};semester==#{faculty_semester.code}").limit(limit)
    @data.auto_paginate = paginate
  end

  def results
    { resource => @data, faculty_semester: @faculty_semester }
  end

  class << self
    attr_accessor :resource

    def [](resource)
      Class.new(self).tap do |cls|
        cls.resource = resource
      end
    end
  end

  def resource
    self.class.resource
  end

end
