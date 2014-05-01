module Sirius
  module Enum

    def from_numeric(day_number)
      day = values[day_number]
      raise "Invalid #{self.name.demodulize} number #{day_number}" if day.nil?
      day
    end

    def to_numeric(day)
      day_index = values.find_index(day)
      raise "Invalid #{self.name.demodulize} value #{day}" if day_index.nil?
      day_index
    end

  end
end
