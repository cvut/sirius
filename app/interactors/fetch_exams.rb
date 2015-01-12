require 'interactors/kosapi_interactor'

class FetchExams < KOSapiInteractor

  def perform(faculty_semester:, limit: 100, paginate: true)
    @rooms = {}
    @faculty_semester = faculty_semester
    client = kosapi_client(faculty_semester)
    @exams = client.exams.where("course.faculty==#{faculty_semester.faculty};semester==#{faculty_semester.code}").limit(limit)
    @exams.auto_paginate = paginate
    @exams.lazy.map(&:room).reject(&:nil?).each do |room|
      @rooms[room.link_id] ||= room
    end
  end

  def results
    { exams: @exams, faculty_semester: @faculty_semester, kosapi_rooms: @rooms.values }
  end

end
