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
      total_parallels = 0
      parallels = fetch_parallels(0, 20, 'B132')
      DB.transaction do
        parallels.take_while do |parallel|
          ParallelFromKOSapi.from_kosapi(parallel)
          total_parallels += 1
          total_parallels < parallels_limit
        end
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
