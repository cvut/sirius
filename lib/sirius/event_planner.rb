require 'models/schedule_exception'
require 'roles/planned_timetable_slot'
require 'models/parallel'
require 'sirius/time_converter'
require 'roles/planned_semester_period'

module Sirius
  class EventPlanner

    def initialize
      @sync = Sync[Event, matching_attributes: [:faculty, :source_type, :source_id, :absolute_sequence_number], skip_updating: [:relative_sequence_number]]
      @exceptions = ScheduleException.all
    end

    def plan_semester(semester)
      time_converter, semester_periods = create_converters(semester)
      slots_dataset(semester).flat_map do |sl|
        slot = PlannedTimetableSlot.new(sl, time_converter)
        events = semester_periods.flat_map do |semester_period|
          slot.generate_events(semester, semester_period)
        end
        number_events(events)
        apply_exceptions(events)
        @sync.perform(events: events)
        slot.clear_extra_events(events)
        events
      end
    end

    def apply_exceptions(events)
      events.each { |evt| @exceptions.each { |ex| ex.apply(evt) if ex.affects?(evt) } }
    end

    private
    def create_converters(semester)
      time_converter = TimeConverter.new(hour_starts: semester.hour_starts, hour_length: semester.hour_duration)
      semester_periods = semester.semester_periods_dataset.where(type: 0).order(:starts_at)
        .map { |p| PlannedSemesterPeriod.new(p) }
      [time_converter, semester_periods]
    end

    def slots_dataset(semester)
      TimetableSlot.join(Parallel, id: :parallel_id).where(semester: semester.code, faculty: semester.faculty).select(Sequel.lit('timetable_slots.*'))
    end

    def number_events(events)
      events.each_with_index do |event, index|
        event.absolute_sequence_number = index + 1
      end
    end

  end
end
