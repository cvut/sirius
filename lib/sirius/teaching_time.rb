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
      @teaching_period == other.teaching_period &&
        @day == other.day &&
        @parity == other.parity &&
        @start_date == other.start_date &&
        @end_date == other.end_date
    end

    def numeric_day
      Date::DAYS_INTO_WEEK[day] + 1
    end

    def to_recurrence_rule(day_offset, schedule_ends_at)
      teaching_day = (numeric_day + day_offset) % 7
      until_date = if @end_date && @end_date < schedule_ends_at
          # The current teaching time is defined in some time interval.
          @end_date
        else
          # The current teaching time is defined in whole semester -> whole scheduling period.
          schedule_ends_at
        end

      IceCube::Rule.weekly(week_frequency, :monday).day(teaching_day).until(until_date)
    end

    def week_frequency
      if parity.nil? || parity == 'both'
        1
      else
        2
      end
    end

  end
end
