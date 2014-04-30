module Sirius
  class ScheduleManager

    def plan_stored_parallels
      semesters = load_semesters
      semesters.each do |sem|
        parallels = Parallel.all
        events = sem.plan_parallels(parallels)
        events.each(&:save)
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
