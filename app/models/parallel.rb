class Parallel < Sequel::Model

  many_to_one :course

  attr_accessor :timetable_slots


  def generate_events(time_converter, calendar_planner)
    teaching_times = teaching_times(time_converter)
    plan_calendar(teaching_times, calendar_planner)
  end

  private
  def teaching_times(time_converter)
    @timetable_slots.map do |slot|
      teaching_period = time_converter.convert_time(slot.first_hour, slot.duration)
      Sirius::TeachingTime.new(teaching_period: teaching_period, day: slot.day, parity: slot.parity)
    end
  end

  def plan_calendar(teaching_times, calendar_planner)
    teaching_times.map{ |tt| tt.plan_calendar(calendar_planner) }
  end

end
