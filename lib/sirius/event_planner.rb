require 'models/schedule_exception'
require 'roles/applied_schedule_exception'
require 'roles/planned_timetable_slot'
require 'models/parallel'
require 'sirius/time_converter'
require 'sirius/semester_calendar'

module Sirius
  class EventPlanner

    def initialize
      @sync = Sync[Event, matching_attributes: [:timetable_slot_id, :absolute_sequence_number]]
      @exceptions = ScheduleException.all.map { |e| AppliedScheduleException.new(e) }
    end

    def plan_semester(semester)
      time_converter, calendar_planner = create_converters(semester)
      TimetableSlot.each do |sl|
        PlannedTimetableSlot.new(sl, time_converter, calendar_planner).tap do |slot|
          events = slot.generate_events
          apply_exceptions(events)
          @sync.perform(events: events)
          slot.clear_extra_events(events)
        end
      end
      renumber_events
    end

    # Recalculates relative_sequence_number for all Events in the database attached to a parallel.
    #
    # Numbering is calculated so that events in single parallel are ordered by start time and then numbered
    # sequentially starting from 1.
    def renumber_events
      DB.run 'with positions as (
          select
            id,
            row_number() over (partition by parallel_id order by starts_at) as position
          from events
          where deleted = false
        )
        update events
          set relative_sequence_number = p.position
        from positions p
        where p.id = events.id;'
    end

    def apply_exceptions(events)
      events.each { |evt| @exceptions.each { |ex| ex.apply(evt) if ex.affects?(evt) } }
    end

    private
    def create_converters(semester)
      time_converter = TimeConverter.new(hour_starts: semester.hour_starts, hour_length: semester.hour_duration)
      semester_calendar = SemesterCalendar.new(teaching_period: Period.new(semester.starts_at, semester.teaching_ends_at), first_week_parity: semester.first_week_parity)
      [time_converter, semester_calendar]
    end

  end
end
