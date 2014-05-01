require 'enum'

class Day
  extend Enum

  DAYS = [nil, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]

  # define all days as public uppercase constants of this class
  DAYS.each do |day|
    const_set(day.upcase, day) unless day.nil?
  end

  # values method for Enum module
  def self.values
    DAYS
  end

end
