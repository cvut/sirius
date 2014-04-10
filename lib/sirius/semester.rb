module Sirius
  class Semester

    def initialize
      @time_converter = ScheduleTimeConverter.new(first_hour: Time.parse('7:30'), hour_length: 45, break_length: 15, break_after: 2)
      @calendar_planner = ScheduleCalendarPlanner.new(teaching_period: Sirius::Period.parse('17.2.2014','16.5.2014'), first_week_parity: :even)
    end

    def plan_parallels(parallels)
      parallels.each { |p| plan_parallel(p) }
    end

    def plan_parallel(parallel)
      teaching_times = parallel.convert_time(@time_converter)
      teaching_times.each{ |tt| tt.plan_calendar(@calendar_planner) }
    end

  end
end

