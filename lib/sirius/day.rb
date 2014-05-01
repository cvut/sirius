module Sirius
  class Day
    extend Enum

    DAYS = [nil, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]

    DAYS.each do |day|
      const_set(day.upcase, day) unless day.nil?
    end

    def self.values
      DAYS
    end

  end
end
