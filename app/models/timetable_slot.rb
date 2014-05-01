class TimetableSlot < Sequel::Model

  PARITIES = [:both, :odd, :even]

  many_to_one :parallel
  many_to_one :room

  def parity
    PARITIES[super]
  end

  def parity=(new_parity)
    parity_index = PARITIES.find_index(new_parity)
    raise "Invalid parity type #{new_parity}" if parity_index.nil?
    super parity_index
  end

  def day
    Day.from_numeric(super)
  end

  def day=(new_day)
    super Day.to_numeric(new_day)
  end

end
