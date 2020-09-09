require 'celluloid'
require 'actors/etl_producer'
require 'actors/etl_consumer'
require 'sirius/time_converter'
require 'roles/planned_timetable_slot'
require 'day'
require 'sirius/faculty_semester_weeks_generator'

# A convertor which receives TeacherTimetableSlots loaded from KOSapi and plans them into
# Events according to semester parameters and semester periods.
class TeacherTimetableSlotTransformer
  include Celluloid
  include ETLProducer
  include ETLConsumer

  def initialize(input, output, semester)
    self.input = input
    self.output = output
    @semester = semester
    @semester_weeks_dates = Sirius::FacultySemesterWeeksGenerator.generate_semester_weeks_dates(@semester)
    @events = nil
  end

  # @param row [Array(KOSapiClient::Entity::TeacherTimetableSlot, String)] teacher timetable slot
  #   together with related teacher username
  # @return [Array<Event>] planned events
  def process_row(row)
    slot, teacher = *row
    plan_events(slot, teacher)
  end

  # @return [Array<Event>] generated events that were not yet synced with the database
  def generate_row
    if processed_row
      pop_processed_row
    else
      raise EndOfData
    end
  end

  # @param slot [KOSapiClient::Entity::TeacherTimetableSlot] teacher timetable slot loaded from KOSapi
  # @param teacher [String] teacher username for the timetable slot
  # @return [Array<Event>] planned events
  def plan_events(slot, teacher)
    periods_query = @semester.semester_periods_dataset
      .where(type: ['teaching', 'exams'])
      .order(:starts_at)
    periods = periods_query.map { |p| PlannedSemesterPeriod.new(p) }
    time_converter = Sirius::TimeConverter.new(
      hour_starts: @semester.hour_starts,
      hour_length: @semester.hour_duration
    )
    # in case the duration is not set, use default duration of 2 hours
    slot.duration = 2 if !slot.duration && !slot.end_time
    slot.parity = slot.parity.to_s

    unless slot.weeks.blank?
      slot.weeks = parse_weeks(slot.weeks)
      slot.parity = nil
    end

    events = periods.flat_map do |period|
      PlannedTimetableSlot.new(slot, time_converter).generate_events(@semester, period, @semester_weeks_dates)
    end

    events.each_with_index do |e, i|
      e.event_type = 'teacher_timetable_slot'
      e.source_type = 'teacher_timetable_slot'
      e.source_id = slot.id
      e.teacher_ids = [teacher]
      e.student_ids = []
      e.absolute_sequence_number = i + 1
      e.name = Sequel.hstore({cs: slot.title})
    end

    events
  end

  private

  # FIXME: Copy-pasted from the ConvertTTS interactor.
  def parse_weeks(weeks)
    weeks.split(',').flat_map { |interval|
      if interval.include?('-')
        from, to = interval.split('-', 2)
        (Integer(from)..Integer(to)).to_a
      else
        Integer(interval)
      end
    }.sort.uniq
  end
end
