require 'spec_helper'
require 'roles/planned_timetable_slot'
require 'models/person'
require 'sirius/time_converter'
require 'roles/planned_semester_period'

describe PlannedTimetableSlot do

  let(:slot) { Fabricate(:timetable_slot, first_hour: 1, duration: 2, parity: :both, day: :monday) }
  let(:period) { Period.parse('7:30', '9:00') }
  let(:converter) { instance_double(Sirius::TimeConverter, convert_time: period) }
  let(:semester_calendar) { instance_double(PlannedSemesterPeriod, plan: [period]) }
  let(:faculty_semester) { Fabricate.build(:faculty_semester) }
  subject(:planned_slot) { described_class.new(slot, converter) }

  describe '#generate_events' do

    it 'converts Timetableslot to events' do
      events = planned_slot.generate_events(faculty_semester, semester_calendar)
      expect(events.size).to be > 0
      expect(events.first).to be_an_instance_of(Event)
    end

    it 'sets deleted flag for deleted timetable slots' do
      slot.deleted_at = Time.now
      events = planned_slot.generate_events(faculty_semester, semester_calendar)
      expect(events.first.deleted).to be_truthy
    end

  end

  describe '#clear_extra_events' do

    let!(:extra_event) do
      Fabricate(:event, absolute_sequence_number: 20, source_type: 'timetable_slot', source_id: slot.id.to_s,
                applied_schedule_exception_ids: [Fabricate(:schedule_exception).id],
                parallel_id: slot.parallel.id)
    end

    let!(:planned_event) do
      Fabricate(:event, source_type: 'timetable_slot', source_id: slot.id.to_s, parallel_id: slot.parallel.id)
    end

    it 'marks extra events as deleted' do
      expect {
        planned_slot.clear_extra_events([planned_event])
        [extra_event, planned_event].each(&:refresh)
      }.to change(extra_event, :deleted).from(false).to(true)
      expect(planned_event.deleted).to be_falsey
    end

    it 'removes any applied_schedule_exceptions from marked event' do
      expect {
        planned_slot.clear_extra_events([planned_event])
        extra_event.refresh
      }.to change(extra_event, :applied_schedule_exception_ids).to(nil)
    end

  end
end
