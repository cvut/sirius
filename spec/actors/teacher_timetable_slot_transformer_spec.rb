require 'spec_helper'
require 'actors/teacher_timetable_slot_transformer'
require 'roles/planned_semester_period'

describe TeacherTimetableSlotTransformer do
  include ActorHelper

  let!(:semester) { Fabricate(:faculty_semester) }

  # One whole week plus following Monday and Tuesday
  let!(:period1) {
    Fabricate(:semester_period,
      faculty_semester: semester,
      starts_at: '2015-10-19',
      ends_at: '2015-10-27'
    )
  }

  # Holiday on Wednesday
  let!(:period2) {
    Fabricate(:holiday_semester_period,
      faculty_semester: semester,
      starts_at: '2015-10-28',
      ends_at: '2015-10-28'
    )
  }

  # Rest of the week after holiday and a whole week after that.
  let!(:period3) {
    Fabricate(:exams_semester_period,
      faculty_semester: semester,
      starts_at: '2015-10-29',
      ends_at: '2015-11-08'
    )
  }

  let(:duration) { 2 }
  let(:slot) do
    Struct.new(:id, :day, :duration, :first_hour, :parity, :title, :start_time, :end_time)
      .new(42, 1, duration, 1, :both, 'meditation', nil, nil)
  end

  let(:teacher) { 'vomackar' }

  let(:transformer_actor) { described_class.new(nil, nil, semester) }

  # Using #bare_object to bypass Celluloid actor proxy
  subject(:transformer) { transformer_actor.bare_object }

  describe '#plan_events' do
    it 'plans semester periods' do
      events = transformer.plan_events(slot, teacher)
      expect(events.count).to be 3
    end

    it 'generates teacher_timetable_slot events' do
      events = transformer.plan_events(slot, teacher)
      expect(events).to all(have_attributes(
        event_type: 'teacher_timetable_slot',
        teacher_ids: ['vomackar'],
        student_ids: []
      ))
    end

    it 'numbers events sequentially starting from one' do
      events = transformer.plan_events(slot, teacher)
      expect(events.map(&:absolute_sequence_number)).to eq (1..events.count).to_a
    end

    context 'when slot duration not set' do
      let(:duration) { nil }

      it 'sets default slot duration to two hours' do
        events = transformer.plan_events(slot, teacher)
        expect(events.first.starts_at).to be_the_same_time_as Time.parse('7:30')
        expect(events.first.ends_at).to be_the_same_time_as Time.parse('9:00')
      end
    end
  end

  describe '#process_row' do

    it 'emits planned events to output' do
      expect(transformer).to receive(:plan_events)
      transformer.process_row([slot, teacher])
    end
  end

  describe '#generate_row' do
    it 'returns processed row when not empty' do
      transformer.processed_row = :foo
      expect(transformer.generate_row).to be :foo
    end

    it 'throws EndOfData when empty' do
      expect { transformer.generate_row }.to raise_error(EndOfData)
    end
  end
end
