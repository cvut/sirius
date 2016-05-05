require 'celluloid'
require 'actors/etl_producer'
require 'actors/etl_consumer'
require 'sirius/time_converter'
require 'roles/planned_timetable_slot'
require 'day'

class TimetableTransformer
  include Celluloid
  include ETLProducer
  include ETLConsumer

  def initialize(input, output, semester)
    self.input = input
    self.output = output
    @semester = semester
    @events = nil
  end

  def process_row(row)
    slot, teacher = *row
    @events = plan_events(slot, teacher)
    unmark_empty!
    produce_row() if buffer_empty?
  end

  def generate_row
    if @events
      row = @events
      @events = nil
      row
    else
      raise EndOfData
    end
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
    # in case the duration is not set, use default duration of 2 hours
    unless slot.duration
      slot.duration = 2
    end
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
