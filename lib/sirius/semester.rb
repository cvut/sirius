module Sirius
  class Semester

    DEFAULT_TIME_CONVERTER = TimeConverter.new(first_hour: Time.parse('7:30'), hour_length: 45, break_length: 15, break_after: 2)
    DEFAULT_CALENDAR_PLANNER = EventPlanner.new(teaching_period: Sirius::Period.parse('17.2.2014','16.5.2014'), first_week_parity: :even)

    def initialize(time_converter: DEFAULT_TIME_CONVERTER, calendar_planner: DEFAULT_CALENDAR_PLANNER)
      @time_converter = time_converter
      @calendar_planner = calendar_planner
    end

    def plan_parallels(parallels)
      parallels.map { |p| p.generate_events(@time_converter, @calendar_planner) }.flatten
    end

  end
end

