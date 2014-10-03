require 'models/schedule_exception'
require 'roles/applied_schedule_exception'
require 'roles/planned_parallel'
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
      Parallel.eager_graph(:timetable_slots).all.each do |parallel|
        parallel = PlannedParallel.new(parallel)
        parallel.timetable_slots.each do |sl|
          PlannedTimetableSlot.new(sl, time_converter, calendar_planner).tap do |slot|
            events = slot.generate_events
            events.each { |evt| @exceptions.each { |ex| ex.apply(evt) if ex.affects?(evt) } }
            @sync.perform(events: events)
            slot.clear_extra_events(events)
          end
        end
        parallel.renumber_events
      end
    end

    private
    def create_converters(semester)
      time_converter = TimeConverter.new(hour_starts: semester.hour_starts, hour_length: semester.hour_duration)
      semester_calendar = SemesterCalendar.new(teaching_period: Period.new(semester.starts_at, semester.teaching_ends_at), first_week_parity: semester.first_week_parity)
      [time_converter, semester_calendar]
    end

  end
end
