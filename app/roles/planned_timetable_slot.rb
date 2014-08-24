require 'role_playing'
require 'sirius/time_converter'
require 'sirius/event_planner'

class PlannedTimetableSlot < RolePlaying::Role

  def initialize(obj, time_converter, event_planner)
    super obj
    @time_converter = time_converter
    @event_planner = event_planner
  end

  def generate_events
    teaching_times = generate_teaching_periods
    event_periods = plan_calendar(teaching_times)
    create_events(event_periods)
  end

  private
  attr_reader :time_converter, :event_planner

  def generate_teaching_periods
    teaching_period = time_converter.convert_time(first_hour, duration)
    Sirius::TeachingTime.new(teaching_period: teaching_period, day: day, parity: parity)
  end

  def plan_calendar(teaching_time)
    teaching_time.plan_calendar(event_planner)
  end

  def create_events(event_periods)
    factory = Sirius::EventFactory.new
    event_periods.map { |period| factory.build_event(period) }
  end

end
