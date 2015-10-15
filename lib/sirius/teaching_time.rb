require 'ice_cube'

module Sirius
  class TeachingTime

    attr_reader :teaching_period, :day
    attr_accessor :parity

    def initialize(teaching_period:, day:, parity:)
      @teaching_period = teaching_period
      @day = day
      @parity = parity
    end

    def week_offset(starting_week_parity)
      if @parity == :both || @parity == starting_week_parity
        0.weeks
      else
        1.week
      end
    end

    def starts_at
      @teaching_period.starts_at
    end

    def ends_at
      @teaching_period.ends_at
    end

    def duration
      ends_at - starts_at
    end

    def ==(other)
      @teaching_period == other.teaching_period && @day == other.day && @parity == other.parity
    end

    def numeric_day
      Date::DAYS_INTO_WEEK[day] + 1
    end

    def to_recurrence_rule(day_offset, schedule_ends_at)
      teaching_day = (numeric_day + day_offset) % 7
      IceCube::Rule.weekly(week_frequency, :monday).day(teaching_day).until(schedule_ends_at)
    end

    def week_frequency
      if parity == :both
        1
      else
        2
      end
    end

  end
end
