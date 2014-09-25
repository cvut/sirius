require 'parity'

class FacultySemester < Sequel::Model


  def first_week_parity
    Parity.from_numeric(super)
  end

  def first_week_parity=(new_parity)
    super Parity.to_numeric(new_parity)
  end

end
