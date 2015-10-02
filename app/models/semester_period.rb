require 'sirius/enums/semester_period_type'
require 'parity'
require 'day'

class SemesterPeriod < Sequel::Model

  many_to_one :faculty_semester

  def type
    Sirius::SemesterPeriodType.from_numeric(super)
  end

  def type=(new_type)
    super Sirius::SemesterPeriodType.to_numeric(new_type)
  end

  def first_week_parity
    Parity.from_numeric(super) if super
  end

  def first_week_parity=(new_parity)
    if new_parity
      super Parity.to_numeric(new_parity)
    else
      super
    end
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

end
