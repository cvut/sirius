require 'parity'
require 'models/semester_period'

class FacultySemester < Sequel::Model

  one_to_many :semester_periods

  def self.active_for(source_type)
    if source_type == :parallels
      where(update_parallels: true)
    else
      where(update_other: true)
    end
  end

  def self.find_by_date(date, faculty_id)
    where(':date >= starts_at AND :date <= ends_at AND faculty = :faculty',
          date: date, faculty: faculty_id)
      .eager(:semester_periods)
      .limit(1)
      .all.first  # eager loading doesn't work with Dataset.first
  end

  def first_week_parity
    Parity.from_numeric(super)
  end

  def first_week_parity=(new_parity)
    super Parity.to_numeric(new_parity)
  end

end
