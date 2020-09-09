require 'ice_cube'

module Sirius
  class TeachingTime

    attr_reader :teaching_period, :day, :start_date, :end_date
    attr_accessor :parity

    def initialize(teaching_period:, day:, parity: nil, start_date: nil, end_date: nil)
      @teaching_period = teaching_period
      @day = day
      @parity = parity
      @start_date = start_date
      @end_date = end_date
    end

    def start_time
      @teaching_period.starts_at
    end

    def end_time
      @teaching_period.ends_at
    end

    def duration
      end_time - start_time
    end

    def ==(other)
      @teaching_period == other.teaching_period && @day == other.day && @parity == other.parity && @start_date == other.start_date && @end_date == other.end_date
    end

    def numeric_day
      Date::DAYS_INTO_WEEK[day] + 1
    end

    def teaching_day(day_offset)
      (numeric_day + day_offset) % 7
    end

    def to_recurrence_rule(day_offset, schedule_ends_at)
      teaching_day = teaching_day(day_offset)
      if @end_date != nil && @end_date < schedule_ends_at
        # current teaching time is defined in some time interval
        IceCube::Rule.weekly(week_frequency, :monday).day(teaching_day).until(@end_date)
      else
        # current teaching time is defined in whole semester -> whole scheduling period
        IceCube::Rule.weekly(week_frequency, :monday).day(teaching_day).until(schedule_ends_at)
      end
    end

    # Returns true if current teaching time is defined only in some weeks in semester.
    def only_some_weeks?
      @parity == nil && !@start_date != nil && !@end_date != nil
    end

    def week_frequency
      if only_some_weeks? || @parity == 'both'
        1
      else
        2
      end
    end
  end
end
