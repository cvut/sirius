require 'period'

module Sirius

  class TimeConverter

    # Initializes converter with timetable
    # parameters required for conversion.
    #
    # @param first_hour [Time] Time when the first hour of schedule starts.
    # @param hour_length [Float] Duration of single teaching hour in minutes.
    # @param break_length [Float] Duration of break in minutes.
    # @param break_after [Integer] After how many teaching hours a break occurs.
    def initialize( first_hour:, hour_length:, break_length:, break_after: )
      @first_hour = first_hour
      @hour_length = hour_length
      @break_length = break_length
      @break_after = break_after
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
      start_time = @first_hour + ( ( start_hour - 1 ) * @hour_length ).minutes + ( ( ( start_hour - 1 ) / @break_after ) * @break_length ).minutes
      end_time = start_time + (@hour_length * duration).minutes
      Period.new(start_time, end_time)
    end
  end
end

