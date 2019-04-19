require 'date_refinements'
require 'models/semester_period'
require 'sequel/extensions/core_refinements'

class FacultySemester < Sequel::Model
  using ::DateRefinements
  using Sequel::CoreRefinements

  one_to_many :semester_periods, order: :id

  def self.active_for(source_type)
    if source_type == :parallels
      where(update_parallels: true)
    else
      where(update_other: true)
    end
  end

  def self.find_by_date(date, faculty_id)
    where(':date >= starts_at AND :date <= ends_at AND faculty = :faculty'
          .lit(date: date, faculty: faculty_id))
      .eager(:semester_periods)
      .limit(1)
      .all.first  # eager loading doesn't work with Dataset.first
  end

  ##
  # Finds faculty semesters with periods that overlap the specified date range.
  # Note that the returned semester objects may *not* contain the full set of
  # associated periods, but only a subset that overlaps the date range.
  #
  # @param start_date [Date] date of the first week to return (will be
  #   rounded to the beginning of the week).
  # @param end_date [Date] date of the last week to retun (will be rounded to
  #   the beginning of the week).
  # @param faculty_id [Fixnum] organizational number of the faculty.
  # @return [Array<FacultySemester>] faculty semesters sorted by `start_date`.
  #
  def self.find_by_date_range_with_periods(start_date, end_date, faculty_id)
    where('faculty = ? AND (starts_at, ends_at) OVERLAPS (?, ?)'
          .lit(faculty_id, start_date.start_of_week, end_date))
      .order_by(:starts_at)
      .eager(semester_periods: ->(ds) { ds.where('starts_at < ?'.lit(end_date.end_of_week)) })
      .all  # <- this is necessary for eager to work correctly!
  end
end
