require 'parity'

class FacultySemester < Sequel::Model

  def self.active_for(source_type)
    if source_type == :parallels
      where(update_parallels: true)
    else
      where(update_other: true)
    end
  end

  def first_week_parity
    Parity.from_numeric(super)
  end

  def first_week_parity=(new_parity)
    super Parity.to_numeric(new_parity)
  end

end
