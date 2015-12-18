require 'corefines'
require 'day'
require 'models/faculty_semester'

module SiriusApi
  class SemesterDay
    using Corefines::Object::then

    attr_reader :date, :semester

    def initialize(semester, date)
      @semester = semester.freeze
      @date = date.freeze
    end

    # Finds FacultySemester that includes the specified date and returns
    # an instance of SemesterDay that represents this date in context
    # of the semester. If no semester for the date is found, then it returns nil.
    def self.resolve(date, faculty_id)
      FacultySemester
        .find_by_date(date, faculty_id)
        .then { |sem| new(sem, date) }
    end

    # Returns a Period that includes this date.
    def period
      @period ||= @semester.semester_periods.find do |p|
        @date >= p.starts_at && @date <= p.ends_at
      end
    end

    # Returns the day of calendar week (1-7, Monday is 1).
    # It may not be the same as a real calendar day!
    def cwday
      return @date.cwday unless period.first_day_override

      @cwday ||= begin
        offset = Day.to_numeric(period.first_day_override) - period.starts_at.cwday
        wday = @date.wday + offset
        (wday - 1) % 7 + 1  # convert 0 to 7 (Sunday)
      end
    end

    # Returns name of this day.
    # @see #cwday
    def wday_name
      Day.from_numeric(cwday)
    end

    # Returns parity of this day (+:even+, or +:odd+), if it's inside a teaching
    # period; otherwise returns nil.
    def week_parity
      return if period.type != :teaching

      @week_parity ||= begin
        first_parity = period.first_week_parity == :even ? 0 : 1
        parity = (period.starts_at.cweek + @date.cweek + first_parity) % 2
        parity == 0 ? :even : :odd
      end
    end

    # Returns ordinal number of this week among weeks of the same type in
    # the semester.
    def week_num
      @week_num ||= begin
        periods = @semester.semester_periods
          .find_all { |p| p.type == period.type && p.starts_at <= @date }
          .sort_by(&:starts_at)

        # Weeks is an array of calendar week numbers for each period,
        # e.g. [10, 11, 13, 14]
        weeks = periods.reduce([]) do |weeks, p|
          weeks | (p.starts_at.cweek..p.ends_at.cweek).to_a
        end

        # Index in array corresponds to the semester week number, but starting
        # from zero.
        weeks.index(@date.cweek) + 1
      end
    end
  end
end
