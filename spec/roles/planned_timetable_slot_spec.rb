require 'spec_helper'
require 'roles/planned_timetable_slot'
require 'models/person'
require 'sirius/time_converter'
require 'roles/planned_semester_period'

describe PlannedTimetableSlot do

  let(:slot) { Fabricate(:timetable_slot, first_hour: 1, duration: 2, parity: 'both', day: :monday) }
  let(:slot_with_weeks_and_times) { Fabricate(:timetable_slot, first_hour: 1, duration: 2, parity: nil, day: :monday, start_time: Time.parse('1901-01-01 07:30:00'), end_time: Time.parse('1901-01-01 08:10:00'), weeks: "1,3") }
  let(:period) { Period.parse('7:30', '9:00') }
  let(:semester_calendar) { PlannedSemesterPeriod.new(Fabricate(:teaching_semester_period)) }
  let(:faculty_semester) { Fabricate.build(:faculty_semester) }
  let(:converter) { Sirius::TimeConverter.new(hour_starts: faculty_semester.hour_starts, hour_length: faculty_semester.hour_duration) }
  let(:weeks_dates) {[[Date.parse("2014-09-22"), Date.parse("2014-09-28")], [Date.parse("2014-09-29"), Date.parse("2014-10-05")], [Date.parse("2014-10-06"), Date.parse("2014-10-12")]]}
  subject(:planned_slot) { described_class.new(slot, converter) }
  subject(:planned_slot_with_weeks_and_times) { described_class.new(slot_with_weeks_and_times, converter) }

  describe '#generate_events' do

    it 'converts Timetableslot to events' do
      events = planned_slot.generate_events(faculty_semester, semester_calendar, weeks_dates)
      expect(events.size).to eq 13
      expect(events.first).to be_an_instance_of(Event)
    end

    it 'converts Timetableslot with weeks and times to events' do
      events = planned_slot_with_weeks_and_times.generate_events(faculty_semester, semester_calendar, weeks_dates)
      expect(events.size).to eq 2
      expect(events.first).to be_an_instance_of(Event)
      expect(events.first.starts_at.strftime("%H:%M")).to eq "07:30"
      expect(events.first.ends_at.strftime("%H:%M")).to eq "08:10"
    end

    it 'sets deleted flag for deleted timetable slots' do
      slot.deleted_at = Time.now
      events = planned_slot.generate_events(faculty_semester, semester_calendar, weeks_dates)
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
