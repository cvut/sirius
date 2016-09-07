require 'day'
require 'models/room'

class TimetableSlot < Sequel::Model

  many_to_one :parallel
  many_to_one :room

  def day
    Day.from_numeric(super)
  end

  def day=(new_day)
    super Day.to_numeric(new_day)
  end

end
