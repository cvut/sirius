require 'sirius/semester'

module Sirius
  class ScheduleManager

    def initialize(client = KOSapiClient.client)
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

    def fetch_and_store_parallels
      current_semester = 'B132'
      parallels = @client.parallels.where('course.faculty' => 18000, semester: current_semester).offset(0).limit(20)
      parallels.each do |parallel|

      end
    end


    private
    def load_semesters
      [Semester.new]
    end

  end
end
