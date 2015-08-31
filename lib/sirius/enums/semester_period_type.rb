require 'enum'

module Sirius
  class SemesterPeriodType
    extend Enum

    TYPES = [:teaching, :exams, :holiday]

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
