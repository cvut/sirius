require 'role_playing'
require 'sirius/time_converter'
require 'sirius_api/semester_schedule'

class PlannedTimetableSlot < RolePlaying::Role

  def initialize(obj, time_converter)
    super obj
    @time_converter = time_converter
  end

  def generate_events(faculty_semester, semester_period, weeks_starts, weeks_ends)
    teaching_times = generate_teaching_times(weeks_starts, weeks_ends)
    event_periods = []
    # count event periods in current semester period in all week intervals
    teaching_times.each do |teaching_time|
      periods = semester_period.plan(teaching_time)
      event_periods = event_periods + periods
    end
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

  def generate_teaching_period
    if !start_time.blank? && !end_time.blank?
      # timetable slot has start time and end time already specified
      teaching_period = Period.new(start_time, end_time)
    else
      teaching_period = time_converter.convert_time(first_hour, duration)
    end
    teaching_period
  end

  def generate_teaching_times(weeks_starts, weeks_ends)
    teaching_period = generate_teaching_period

    if weeks.blank?
      #  timetable with even/odd week parity
      [Sirius::TeachingTime.new(teaching_period: teaching_period, day: day, parity: parity)]
    else
      #  timetable customized for different weeks defined by string

      week_intervals.map do |interval|
        if interval.length > 2
          # true interval
          interval_split = interval.split('-')
          Sirius::TeachingTime.new(teaching_period: teaching_period, day: day, start_date: weeks_starts[Integer(interval_split[0]) - 1], end_date: weeks_ends[Integer(interval_split[1]) - 1])
        else
          # one week
          week_number = Integer(interval) - 1
          Sirius::TeachingTime.new(teaching_period: teaching_period, day: day, start_date: weeks_starts[week_number], end_date: weeks_ends[week_number])
        end
      end
    end
  end

  def week_intervals
    weeks.split(',')
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
