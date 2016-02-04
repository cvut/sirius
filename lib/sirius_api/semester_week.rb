require 'corefines'
require 'forwardable'
require 'date_refinements'

module SiriusApi
  class SemesterWeek
    extend Forwardable

    using Corefines::Object::then
    using Corefines::Enumerable::map_by
    using ::DateRefinements

    class << self
      ##
      # Generates {SemesterWeek}s for the given {FacultySemester}.
      #
      # @param semester [FacultySemester]
      # @return [Array<SemesterWeek>] an array of semester weeks sorted by date.
      #
      def resolve_weeks(semester)
        semester.semester_periods
          .sort_by(&:starts_at)
          .flat_map { |per| index_period_by_weeks per }
          .map_by { |date, per| [date, per] }
          .map { |date, pers| SemesterWeek.new(semester, pers, date) }
          .sort_by(&:start_date)
          .tap { |weeks| add_teaching_week_nums! weeks }
      end

      private

      ##
      # @example
      #   <SemesterPeriod @starts_at="2016-01-07" @ends_at="2016-01-24">
      #   #=> [
      #         ["2016-01-04", <SemesterPeriod>],
      #         ["2016-01-11", <SemesterPeriod>],
      #         ["2016-01-18", <SemesterPeriod>]
      #       ]
      #
      # @param period [SemesterPeriod]
      # @return [Array] an array of two element arrays; the first element is
      #   a Date that represents the beginning of a week and the second one is
      #   the given period.
      def index_period_by_weeks(period)
        period.starts_at
          .start_of_week
          .step(period.ends_at, 7).to_a
          .product([period])
      end

      ##
      # Fills ordinal number (1-based) of a teaching week into each
      # of the given {SemesterWeek} that contains a teaching period.
      #
      # @note This method mutates the given objects!
      # @param weeks [Array<SemesterWeek>]
      #
      def add_teaching_week_nums!(weeks)
        weeks
          .select(&:teaching?)
          .each_with_index do |o, i|
            o.instance_variable_set(:@teaching_week, i + 1)
          end
      end
    end

    # @!attribute [r] cweek
    #   @return [Fixnum] the calendar week number per ISO 8601 (1-53).
    # @!attribute [r] cwyear
    #   @return [Fixnum] the calendar week based year per ISO 8601.
    def_delegators :@start_date, :cweek, :cwyear, :year

    # @return [Array<SemesterPeriod>] an array of semester periods included or
    #   intersecting this week.
    attr_reader :periods

    # @return [FacultySemester] the semester that contains this week.
    attr_reader :semester

    # @return [Date] the first day (monday) of this week.
    attr_reader :start_date

    # @return [Fixnum, nil] an ordinal number of the teaching week within the
    #   semester, or `nil` if this week isn't inside a regular teaching period.
    attr_reader :teaching_week

    ##
    # @param semester [FacultySemester] (see #semester)
    # @param periods [Array<SemesterPeriod>] (see #periods)
    # @param start_date [Date] (see #start_date)
    # @param teaching_week [Fixnum, nil] (see #teaching_week)
    def initialize(semester, periods, start_date, teaching_week = nil)
      @semester = semester
      @periods = periods.freeze
      @start_date = start_date.freeze
      @teaching_week = teaching_week
    end

    ##
    # @return [Array<Symbol>] a set of regular period types within this week.
    def period_types
      @period_types ||= @periods.reject(&:irregular?).map(&:type).uniq.freeze
    end

    ##
    # @return [Boolean] `true` if this week includes a regular teaching period,
    #   `false` otherwise.
    def teaching?
      period_types.include? :teaching
    end

    ##
    # Returns a parity of this week within a regular teaching semester period.
    # If there's no such period, the method returns `nil`.
    #
    # The calculation is based on difference between the period's start date and
    # and this week's date, shifted by the period's `first_week_parity`.
    #
    # @return [Symbol, nil] `:even`, `:odd`, or `nil`
    #
    def week_parity
      return @week_parity if defined? @week_parity

      @week_parity = @periods
        .find { |p| p.regular? && p.teaching? }
        .then do |period|
          weeks_since_start = ((@start_date - period.starts_at.start_of_week) / 7).floor.abs
          first_parity = period.first_week_parity == :even ? 0 : 1
          parity = (weeks_since_start + first_parity) % 2

          parity == 0 ? :even : :odd
        end
    end

    def eql?(other)
      %w[class periods semester start_date teaching_week].all? do |att|
        other.send(att) == self.send(att)
      end
    end

    alias_method :==, :eql?
  end
end
