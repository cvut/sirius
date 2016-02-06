require 'forwardable'
require 'day'

module SiriusApi
  class SemesterDay
    extend Forwardable

    # @return [Date]
    attr_reader :date

    # @return [SemesterPeriod]
    attr_reader :period

    # @return [Fixnum, nil] an ordinal number of the teaching week within the
    #   semester, or `nil` if this day isn't inside a regular teaching period.
    attr_reader :teaching_week

    # @!attribute [r] semester
    #   @return [FacultySemester] a semester that contains this day.
    def_delegator :@period, :faculty_semester, :semester

    # @!attribute [r] irregular
    #   @return [Boolean] whether this day is irregular.
    def_delegator :@period, :irregular


    ##
    # @param period [SemesterPeriod] (see #period)
    # @param date [Date] (see #date)
    # @param teaching_week [Fixnum, nil] (see #teaching_week)
    def initialize(period, date, teaching_week)
      @period = period
      @date = date.freeze
      @teaching_week = teaching_week
    end

    ##
    # Returns the day of calendar week. It may not be the same as a real calendar
    # day, due to a semester period with day_override.
    #
    # @return [Fixnum] the day of calendar week per ISO 8601 (1-7, Monday is 1).
    #
    def cwday
      return @date.cwday unless period.first_day_override

      @cwday ||= begin
        offset = Day.to_numeric(period.first_day_override) - period.starts_at.cwday
        wday = @date.wday + offset
        (wday - 1) % 7 + 1  # convert 0 to 7 (Sunday)
      end
    end

    ##
    # @return [Symbol] name of this day.
    # @see #cwday
    def wday_name
      Day.from_numeric(cwday)
    end

    ##
    # Returns a parity of this day within a teaching semester period.
    # If this day is not within a teaching period, the method returns `nil`.
    #
    # Unlike the same named method in {SemesterWeek}, this one considers even
    # irregular periods!
    #
    # @return [Symbol, nil] `:even`, `:odd`, or `nil`
    # @see SemesterPeriod#week_parity
    #
    def week_parity
      return @week_parity if defined? @week_parity
      @week_parity = @period.week_parity(@date)
    end

    def eql?(other)
      %w[class date period teaching_week].all? do |att|
        other.send(att) == self.send(att)
      end
    end

    alias_method :==, :eql?
  end
end
