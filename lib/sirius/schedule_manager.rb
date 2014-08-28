require 'sirius/semester'
require 'models/parallel'
require 'roles/planned_timetable_slot'
require 'interactors/import_updated_parallels'
require 'interactors/import_students'
require 'models/schedule_exception'
require 'roles/applied_schedule_exception'
require 'roles/planned_parallel'

module Sirius
  class ScheduleManager

    DEFAULT_TIME_CONVERTER = TimeConverter.new(first_hour: Time.parse('7:30'), hour_length: 45, break_length: 15, break_after: 2)
    DEFAULT_CALENDAR_PLANNER = EventPlanner.new(teaching_period: Period.parse('22.9.2014','20.12.2014'), first_week_parity: :odd)

    def initialize(time_converter: DEFAULT_TIME_CONVERTER, calendar_planner: DEFAULT_CALENDAR_PLANNER)
      @time_converter = time_converter
      @calendar_planner = calendar_planner
      @semester = 'B141'
      @faculty = 18000
    end

    def plan_stored_parallels
      sync = Sync[Event, matching_attributes: [:timetable_slot_id, :absolute_sequence_number]]
      exceptions = ScheduleException.all.map { |e| AppliedScheduleException.new(e) }
      Parallel.eager_graph(:timetable_slots).all.each do |parallel|
        parallel = PlannedParallel.new(parallel)
        parallel.timetable_slots.each do |sl|
          PlannedTimetableSlot.new(sl, @time_converter, @calendar_planner).tap do |slot|
            events = slot.generate_events
            events.each {|evt| exceptions.each {|ex| ex.apply(evt) if ex.affects?(evt) } }
            sync.perform(events: events)
            slot.clear_extra_events(events)
          end
        end
        parallel.renumber_events
      end
    end

    def import_parallels(fetch_all: true)
      DB.transaction do
        ImportUpdatedParallels.perform(faculty: @faculty, semester: @semester, fetch_all: fetch_all)
      end
    end

    def import_students
      DB.transaction do
        ImportStudents.perform
      end
    end

  end
end
