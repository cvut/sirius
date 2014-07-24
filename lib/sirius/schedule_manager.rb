require 'sirius/semester'
require 'models/parallel'

module Sirius
  class ScheduleManager

    def initialize(client: KOSapiClient.client)
      @client = client
    end

    def plan_stored_parallels
      semesters = load_semesters
      semesters.map do |sem|
        parallels = Parallel.all
        events = sem.plan_parallels(parallels)
        events.each { |event| event.save }
      end

    end

    def fetch_and_store_parallels(parallels_limit = 20)
      current_semester = 'B132'
      limit = 20
      total_parallels = 0
      offset = 0
      parallels = fetch_parallels(0, limit, current_semester)
      while parallels.count > 0 && total_parallels < parallels_limit
        parallels.each do |parallel|
          Parallel.from_kosapi(parallel)
        end
        total_parallels += parallels.count
        offset += limit
        parallels = fetch_parallels(offset, limit, current_semester)
      end
    end


    private
    def load_semesters
      [Semester.new]
    end

    def fetch_parallels(offset, limit, semester, faculty = 18000)
      @client.parallels.where('course.faculty' => faculty, semester: semester).offset(offset).limit(limit)
    end

  end
end
