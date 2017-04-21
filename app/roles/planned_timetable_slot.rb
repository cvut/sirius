require 'role_playing'
require 'sirius/time_converter'

class PlannedTimetableSlot < RolePlaying::Role

  def initialize(obj, time_converter)
    super obj
    @time_converter = time_converter
  end

  def generate_events(faculty_semester, semester_period)
    teaching_time = generate_teaching_time
    event_periods = semester_period.plan(teaching_time)
    create_events(event_periods, faculty_semester).tap do |events|
      events.map { |e| e.deleted = !!deleted_at }
    end
  end

  def clear_extra_events(planned_events)
    all_events = Event.where(source_type: 'timetable_slot', source_id: id.to_s, deleted: false)
    extra_events = filter_extra_events(all_events, planned_events)
    Event.batch_delete(extra_events.map(&:id))
  end

  def day
    original_day = __getobj__.day
    if original_day.is_a? Numeric
      Day.values[original_day]
    else
      original_day
    end
  end

  private
  attr_reader :time_converter

  def filter_extra_events(all_events, planned_events)
    planned_event_ids = planned_events.map(&:id)
    all_events.find_all { |evt| !planned_event_ids.include?(evt.id) }
  end

  def generate_teaching_time
    teaching_period = time_converter.convert_time(first_hour, duration)
    Sirius::TeachingTime.new(teaching_period: teaching_period, day: day, parity: parity)
  end

  def create_events(event_periods, faculty_semester)
    Sirius::EventFactory.new(self, faculty_semester).build_events(event_periods)
  end

  def deleted_at
    if role_player.respond_to? :deleted_at
      role_player.deleted_at
    else
      false
    end
  end

end
