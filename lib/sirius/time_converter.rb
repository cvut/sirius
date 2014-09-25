require 'period'

module Sirius

  class TimeConverter

    # Initializes converter with timetable
    # parameters required for conversion.
    #
    # @param hour_starts [Array] Times when hours of schedule starts.
    # @param hour_length [Float] Duration of single teaching hour in minutes.
    def initialize( hour_starts:, hour_length:)
      @hour_starts = hour_starts
      @hour_length = hour_length
    end

    # Converts hour data from KOSapi
    # to real start and end time
    #
    # Example calculation with parameters:
    # start_hour = 5
    # duration = 2
    # @first_hour = 7:30
    # @hour_length = 45m
    # @break_length = 15m
    # @break_after = 2
    #
    # start_time = 7:30 + (5-1)*45m + ((5-1)/2)*15m = 7:30 + 180m + 30m = 11:00
    # end_time = 11:00 + 90m = 12:45
    #
    # @param start_hour [Integer] Hour number when the event starts
    # @param duration [Integer] Event duration in whole teaching hours
    # @return [Period] Event start and end times
    #
    def convert_time( start_hour, duration )
      raise "Invalid start hour (#{start_hour}) or duration (#{duration})" if start_hour <= 0 || duration <= 0
      start_time = @hour_starts[start_hour - 1]
      end_time = start_time + (@hour_length * duration).minutes
      Period.new(start_time, end_time)
    end
  end
end

