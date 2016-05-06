require 'faculty_semester'
require 'sirius_api/semester_week'
require 'date_refinements'

module SiriusApi
  module SemesterSchedule
    using Corefines::Object::then
    using ::DateRefinements

    module_function

    ##
    # Returns semester weeks in the given range according to schedule of
    # the specified faculty.
    #
    # @param start_date [Date] date of the first week to return (will be
    #   rounded to the beginning of the week).
    # @param end_date [Date] date of the last week to retun (will be rounded to
    #   the beginning of the week).
    # @param faculty_id [Fixnum] organizational number of the faculty.
    # @return [Array<SemesterWeek>]
    #
    def resolve_weeks(start_date, end_date, faculty_id)
      FacultySemester
        .find_by_date_range_with_periods(start_date, end_date, faculty_id)
        .flat_map do |sem|
          SemesterWeek.resolve_weeks(sem, from: start_date.start_of_week, to: end_date)
        end
    end

    ##
    # Returns a semester week that occurs at the given date according to
    # schedule of the specified faculty.
    #
    # @param date [Date]
    # @param faculty_id (see #resolve_weeks)
    # @return [SemesterWeek, nil] a semester week, or nil of no data.
    #
    def resolve_week(date, faculty_id)
      resolve_weeks(date, date, faculty_id).first
    end

    ##
    # Returns semester days in the given range according to schedule of
    # the specified faculty.
    #
    # @param start_date [Date] date of the first day to return.
    # @param end_date [Date] date of the last day to return.
    # @param faculty_id (see #resolve_weeks)
    # @return [Array<SemesterDay>]
    #
    def resolve_days(start_date, end_date, faculty_id)
      resolve_weeks(start_date, end_date, faculty_id)
        .flat_map(&:days)
        .compact
        .drop_while { |day| day.date < start_date }
        .take_while { |day| day.date <= end_date }
    end

    ##
    # Returns a semester day for the given date according to schedule of
    # the specified faculty.
    #
    # @param date [Date] date of the day to return.
    # @param faculty_id (see #resolve_weeks)
    # @return [SemesterDay, nil] a semester day, or nil if no data.
    #
    def resolve_day(date, faculty_id)
      resolve_week(date, faculty_id)
        .then { |week| week.days[date.cwday - 1] }
    end
  end
end
