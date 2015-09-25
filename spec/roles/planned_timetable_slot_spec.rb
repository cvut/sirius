require 'spec_helper'
require 'roles/planned_timetable_slot'
require 'models/person'
require 'sirius/time_converter'
require 'sirius/semester_calendar'

describe PlannedTimetableSlot do

  describe '#generate_events' do

    let(:slot) { Fabricate(:timetable_slot, first_hour: 1, duration: 2, parity: :both, day: :monday) }
    let(:period) { Period.parse('7:30', '9:00') }
    let(:converter) { instance_double(Sirius::TimeConverter, convert_time: period) }
    let(:semester_calendar) { instance_double(Sirius::SemesterCalendar, plan: [period]) }
    let(:faculty_semester) { Fabricate.build(:faculty_semester) }
    subject(:planned_slot) { described_class.new(slot, converter, semester_calendar) }

    it 'converts Timetableslot to events' do
      events = planned_slot.generate_events(faculty_semester)
      expect(events.size).to be > 0
      expect(events.first).to be_an_instance_of(Event)
    end

    it 'sets deleted flag for deleted timetable slots' do
      slot.deleted_at = Time.now
      events = planned_slot.generate_events(faculty_semester)
      expect(events.first.deleted).to be_truthy
    end

  end

end
