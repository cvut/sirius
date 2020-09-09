require 'role_playing'
require 'ice_cube'
require 'active_support/core_ext/date/calculations'  # next_week

require 'period'
require 'day'

class PlannedSemesterPeriod < RolePlaying::Role

  def plan(teaching_time)
    scheduling_start = combine_date_with_time(
      schedule_start_day(teaching_time),
      teaching_time.start_time
    )

    schedule = IceCube::Schedule.new(scheduling_start, duration: teaching_time.duration)
    schedule.add_recurrence_rule teaching_time.to_recurrence_rule(day_offset, ends_at)
    occurences = schedule.all_occurrences
    occurences.map { |occurence| Period.new(occurence.to_time, occurence + teaching_time.duration) }
  end

  def day_offset
    if first_day_override
      starts_at.wday - Day.to_numeric(first_day_override)
    else
      0
    end
  end

  private

  def combine_date_with_time(date, time)
    Time.new(date.year, date.month, date.day, time.hour, time.min, time.sec)
  end

  def schedule_start_day(teaching_time)
    if teaching_time.start_date
      # Teaching time is defined only in some time interval.
      [starts_at, teaching_time.start_date].max
    elsif teaching_time.parity == 'both' || teaching_time.parity == first_week_parity
      starts_at
    else
      starts_at.next_week(:monday)
    end
  end
end
