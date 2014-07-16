module Enum

  def from_numeric(value_number)
    value = values[value_number]
    raise "Invalid #{self.name.demodulize} number #{value_number}" if value.nil?
    value
  end

  def to_numeric(value)
    return value if value.is_a?(Numeric)
    value_index = values.find_index(value)
    raise "Invalid #{self.name.demodulize} value #{value}" if value_index.nil?
    value_index
  end

end
