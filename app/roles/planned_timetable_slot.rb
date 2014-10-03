require 'role_playing'
require 'sirius/time_converter'
require 'sirius/semester_calendar'

class PlannedTimetableSlot < RolePlaying::Role

  def initialize(obj, time_converter, semester_calendar)
    super obj
    @time_converter = time_converter
    @semester_calendar = semester_calendar
  end

  def generate_events
    teaching_time = generate_teaching_time
    event_periods = plan_calendar(teaching_time)
    create_events(event_periods)
  end

  def clear_extra_events(planned_events)
    all_events = Event.where(timetable_slot_id: id)
    extra_events = filter_extra_events(all_events, planned_events)
    extra_events.each(&:delete)
  end

  private
  attr_reader :time_converter, :semester_calendar

  def filter_extra_events(all_events, planned_events)
    planned_event_ids = planned_events.map(&:id)
    all_events.find_all { |evt| !planned_event_ids.include?(evt.id) }
  end

  def generate_teaching_time
    teaching_period = time_converter.convert_time(first_hour, duration)
    Sirius::TeachingTime.new(teaching_period: teaching_period, day: day, parity: parity)
  end

  def plan_calendar(teaching_time)
    semester_calendar.plan(teaching_time)
  end

  def create_events(event_periods)
    Sirius::EventFactory.new(self).build_events(event_periods)
  end

end
