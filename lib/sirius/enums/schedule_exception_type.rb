require 'enum'

module Sirius
  class ScheduleExceptionType
    extend Enum

    TYPES = [:cancel, :relative_move]

    # define all types as public uppercase constants of this class
    TYPES.each do |type|
      const_set(type.upcase, type) unless type.nil?
    end

    # values method for Enum module
    def self.values
      TYPES
    end
  end
end
