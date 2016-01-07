require 'celluloid'
require 'actors/etl_actor'
require 'sirius/time_converter'
require 'roles/planned_timetable_slot'
require 'day'

class TimetableTransformer
  include Celluloid
  include ETLActor

  def initialize(output, semester)
    set_output(output)
    @semester = semester
  end

  def process_row(slot, teacher)
    events = plan_events(slot, teacher)
    emit_row(events)
  end

  def plan_events(slot, teacher)
    periods_query = @semester.semester_periods_dataset
      .where(type: [:teaching, :exams].map { |it| Sirius::SemesterPeriodType.to_numeric(it) })
      .order(:starts_at)
    periods = periods_query.map { |p| PlannedSemesterPeriod.new(p) }
    time_converter = Sirius::TimeConverter.new(
      hour_starts: @semester.hour_starts,
      hour_length: @semester.hour_duration
    )
    events = periods.flat_map do |period|
      PlannedTimetableSlot.new(slot, time_converter).generate_events(@semester, period)
    end

    events.each_with_index do |e, i|
      e.event_type = 'teacher_timetable'
      e.source = Sequel.hstore({teacher_timetable_slot_id: slot.id})
      e.teacher_ids = [teacher]
      e.student_ids = []
      e.absolute_sequence_number = i + 1
      e.name = Sequel.hstore({cs: slot.title})
    end

    events
  end
end
