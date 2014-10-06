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
      Parallel.eager_graph(:timetable_slots).all.each do |parallel|
        parallel.timetable_slots.each do |sl|
          PlannedTimetableSlot.new(sl, time_converter, calendar_planner).tap do |slot|
            events = slot.generate_events
            events.each { |evt| @exceptions.each { |ex| ex.apply(evt) if ex.affects?(evt) } }
            @sync.perform(events: events)
            slot.clear_extra_events(events)
          end
        end
      end
      renumber_events
    end

    def renumber_events
      Parallel.each do |parallel|
        events = Event.where(parallel_id: parallel.id, deleted: false).order(:starts_at).all
        relative_seq = 0
        events.each do |evt|
          evt.relative_sequence_number = relative_seq += 1
          evt.save
        end
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
