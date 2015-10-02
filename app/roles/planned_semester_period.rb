require 'role_playing'
require 'ice_cube'

require 'period'

class PlannedSemesterPeriod < RolePlaying::Role

  def plan(teaching_time)
    week_offset = teaching_time.week_offset(first_week_parity)
    scheduling_start = combine_date_with_time(starts_at, teaching_time.starts_at) + week_offset
    event_duration = (teaching_time.ends_at - teaching_time.starts_at)

    event_schedule = IceCube::Schedule.new(scheduling_start, duration: event_duration)
    event_schedule.add_recurrence_rule to_recurrence_rule(teaching_time)
    event_schedule.all_occurrences.map { |event_start| Period.new(event_start.to_time, event_start + event_duration) }
  end

  private

  def to_recurrence_rule(teaching_time)
    week_frequency = 1 # every week by default
    week_frequency = 2 if teaching_time.parity != :both
    IceCube::Rule.weekly(week_frequency, :monday).day(teaching_time.day).until(ends_at)
  end

  def combine_date_with_time(date, time)
    Time.new(date.year, date.month, date.day, time.hour, time.min, time.sec)
  end
end
