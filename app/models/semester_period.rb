require 'sirius/enums/semester_period_type'
require 'day'
require 'date_refinements'

class SemesterPeriod < Sequel::Model
  using ::DateRefinements

  many_to_one :faculty_semester

  def type
    Sirius::SemesterPeriodType.from_numeric(super)
  end

  def type=(new_type)
    super Sirius::SemesterPeriodType.to_numeric(new_type)
  end

  def teaching?
    type == :teaching
  end

  def first_day_override
    Day.from_numeric(super) if super
  end

  def first_day_override=(new_override)
    if new_override
      super Day.to_numeric(new_override)
    else
      super
    end
  end

  def validate
    super
    if starts_at > ends_at
      errors.add(:starts_at, 'cannot be after ending')
    end
    if (type == :teaching) && first_week_parity.nil?
      errors.add(:first_week_parity, 'cannot be null for teaching period')
    end
  end

  def regular?
    !irregular
  end

  # @return [Boolean] whether the given date is inside this period.
  def include?(date)
    date >= starts_at && date <= ends_at
  end

  ##
  # Resolves a teaching week parity for the given date within this semester
  # period. If this period is not a teaching period, the method returns `nil`.
  #
  # The calculation is based on difference between the period's start date and
  # and the given date, shifted by the period's `first_week_parity`.
  #
  # @param date [Date]
  # @return [String, nil] `'even'`, `'odd'`, or `nil`
  # @raise [ArgumentError] if the date's week is not within this period.
  #
  def week_parity(date)
    return if type != :teaching

    if date < starts_at.start_of_week || date > ends_at.end_of_week then
      fail ArgumentError, "The date's week is not within this period"
    end

    weeks_since_start = ((date.start_of_week - starts_at.start_of_week) / 7).abs.floor
    first_parity = first_week_parity == 'even' ? 0 : 1
    parity = (weeks_since_start + first_parity) % 2

    parity == 0 ? 'even' : 'odd'
  end

  alias_method :irregular?, :irregular
end
