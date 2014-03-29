module Sirius

  class ScheduleCalendarPlanner

    def initialize( params = {} )
      @schedule_start = params[:schedule_start]
      @schedule_end = params[:schedule_end]
      @first_week_parity = params[:first_week_parity]
    end

    def plan(parallel)
      week_offset = 0.weeks
      week_offset = 1.week if parallel[:parity] != :both && parallel[:parity] != @first_week_parity

      event_start = @schedule_start + parallel[:start_time].seconds_since_midnight.seconds + week_offset
      event_duration = (parallel[:end_time] - parallel[:start_time])
      event_schedule = IceCube::Schedule.new(event_start, duration: event_duration)
      event_schedule.add_recurrence_rule to_recurrence_rule(parallel)
      event_schedule.all_occurrences.map{ |event_start| { starts_at: event_start, ends_at: event_start + event_duration } }
    end

    private
    def day_to_offset(day_of_the_week)
      case day_of_the_week
        when :monday
          0
        when :tuesday
          1
        when :wednesday
          2
        when :thursday
          3
        when :friday
          4
        when :saturday
          5
        when :sunday
          6
        else
          raise "Unknown day #{day_of_the_week}"
      end
    end

    def to_recurrence_rule(parallel)
      week_frequency = 1 #every week by default
      week_frequency = 2 if parallel[:parity] != :both

      IceCube::Rule.weekly(week_frequency, :monday).day(parallel[:day]).until(@schedule_end)
    end

  end

end

