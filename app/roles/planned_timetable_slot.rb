require 'role_playing'
require 'sirius/time_converter'

class PlannedTimetableSlot < RolePlaying::Role

  def initialize(obj, time_converter, semester_calendar)
    super obj
    @time_converter = time_converter
    @semester_calendar = semester_calendar
  end

  def generate_events(faculty_semester)
    teaching_time = generate_teaching_time
    event_periods = plan_calendar(teaching_time)
    create_events(event_periods, faculty_semester).tap do |events|
      events.map { |e| e.deleted = !!deleted_at }
    end
  end

  def clear_extra_events(planned_events)
    all_events = Event.where(timetable_slot_id: id, deleted: false)
    extra_events = filter_extra_events(all_events, planned_events)
    Event.where(id: extra_events.map(&:id), deleted: false).update(deleted: true, applied_schedule_exception_ids: nil)
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

  def create_events(event_periods, faculty_semester)
    Sirius::EventFactory.new(self, faculty_semester).build_events(event_periods)
  end

end
