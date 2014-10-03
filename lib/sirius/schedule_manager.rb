require 'sirius/semester'
require 'models/parallel'
require 'models/faculty_semester'
require 'roles/planned_timetable_slot'
require 'interactors/import_updated_parallels'
require 'interactors/import_students'
require 'models/schedule_exception'
require 'roles/applied_schedule_exception'
require 'roles/planned_parallel'

module Sirius
  class ScheduleManager

    def initialize
      @active_semesters = FacultySemester.active
    end

    def plan_stored_parallels
      sync = Sync[Event, matching_attributes: [:timetable_slot_id, :absolute_sequence_number]]
      exceptions = ScheduleException.all.map { |e| AppliedScheduleException.new(e) }
      @active_semesters.each do |sem|
        time_converter, calendar_planner = create_converters(sem)
        Parallel.eager_graph(:timetable_slots).all.each do |parallel|
          parallel = PlannedParallel.new(parallel)
          parallel.timetable_slots.each do |sl|
            PlannedTimetableSlot.new(sl, time_converter, calendar_planner).tap do |slot|
              events = slot.generate_events
              events.each {|evt| exceptions.each {|ex| ex.apply(evt) if ex.affects?(evt) } }
              sync.perform(events: events)
              slot.clear_extra_events(events)
            end
          end
          parallel.renumber_events
        end
      end
    end

    def import_parallels(fetch_all: true)
      DB.transaction do
        @active_semesters.each do |sem|
          ImportUpdatedParallels.perform(faculty: sem.faculty, semester: sem.code, fetch_all: fetch_all)
        end
      end
    end

    def import_students
      DB.transaction do
        ImportStudents.perform
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
