require 'sirius/semester'

module Sirius
  class ScheduleManager

    def plan_stored_parallels
      semesters = load_semesters
      semesters.map do |sem|
        parallels = Parallel.all
        events = sem.plan_parallels(parallels)
        events.each { |event| event.save }
      end

    end

    def fetch_and_store_parallels

    end


    private
    def load_semesters
      [Semester.new]
    end



  end
end
