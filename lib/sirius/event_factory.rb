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
      event.timetable_slot = @slot
      event.parallel = @slot.parallel
      event.room = @slot.room
      event.course = @slot.parallel.course
      event.period = event_period
      event.absolute_sequence_number = absolute_seq
      event.event_type = @slot.parallel.parallel_type
      event.deleted = false
      event.faculty = @faculty_semester.faculty
      event.semester = @faculty_semester.code
      event.capacity = @slot.parallel.capacity
      event
    end
  end
end
