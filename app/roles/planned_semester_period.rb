require 'role_playing'
require 'ice_cube'

require 'period'
require 'day'

class PlannedSemesterPeriod < RolePlaying::Role

  def plan(teaching_time)
    week_offset = teaching_time.week_offset(first_week_parity)
    scheduling_start = combine_date_with_time(starts_at, teaching_time.starts_at) + week_offset

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
end
