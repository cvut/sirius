class TimetableSlot < Sequel::Model

  DAYS = [nil, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]
  PARITIES = [:both, :odd, :even]

  many_to_one :parallel
  many_to_one :room

  def parity
    PARITIES[super]
  end

  def parity=(new_parity)
    numerical_parity = case new_parity
                    when :odd then 1
                    when :even then 2
                    when :both then 0
                    else raise "Invalid parity type #{new_parity}"
                       end
    super numerical_parity
  end

  def day
    DAYS[super]
  end

  def day=(new_day)
    day_index = DAYS.find_index(new_day)
    raise "Invalid day name #{new_day}" if day_index.nil?
    super day_index
  end

end
