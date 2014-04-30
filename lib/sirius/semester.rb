module Sirius
  class Semester

    def initialize
      @time_converter = TimeConverter.new(first_hour: Time.parse('7:30'), hour_length: 45, break_length: 15, break_after: 2)
      @calendar_planner = EventPlanner.new(teaching_period: Sirius::Period.parse('17.2.2014','16.5.2014'), first_week_parity: :even)
    end

    def plan_parallels(parallels)
      parallels.each { |p| p.generate_events(@time_converter, @calendar_planner) }
    end



  end
end

