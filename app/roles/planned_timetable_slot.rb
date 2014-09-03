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

  def clear_extra_events(planned_events)
    all_events = Event.where(timetable_slot_id: id)
    extra_events = filter_extra_events(all_events, planned_events)
    extra_events.each(&:delete)
  end

  private
  attr_reader :time_converter, :event_planner

  def filter_extra_events(all_events, planned_events)
    planned_event_ids = planned_events.map(&:id)
    all_events.find_all { |evt| !planned_event_ids.include?(evt.id) }
  end

  def generate_teaching_periods
    teaching_period = time_converter.convert_time(first_hour, duration)
    Sirius::TeachingTime.new(teaching_period: teaching_period, day: day, parity: parity)
  end

  def plan_calendar(teaching_time)
    teaching_time.plan_calendar(event_planner)
  end

  def create_events(event_periods)
    Sirius::EventFactory.new(self).build_events(event_periods)
  end

end
