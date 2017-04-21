require 'models/event'

module Sirius
  class EventFactory

    def initialize(slot, faculty_semester)
      @slot = slot
      @faculty_semester = faculty_semester
    end

    def build_events(periods)
      absolute_seq = 0
      periods.map do |period|
        build_event(period, absolute_seq += 1)
      end
    end

    def build_event(event_period, absolute_seq)
      event = Event.new
      event.period = event_period
      event.absolute_sequence_number = absolute_seq
      event.deleted = false
      event.faculty = @faculty_semester.faculty
      event.semester = @faculty_semester.code
      event.applied_schedule_exception_ids = nil
      event.source_id = @slot.id
      if @slot.respond_to? :parallel
        event.parallel = @slot.parallel
        event.course = @slot.parallel.course
        event.event_type = @slot.parallel.parallel_type
        event.capacity = @slot.parallel.capacity
        event.source_type = 'timetable_slot'
      else
        event.source_type = 'teacher_timetable_slot'
      end
      event.room = @slot.room if @slot.respond_to? :room
      event
    end
  end
end
