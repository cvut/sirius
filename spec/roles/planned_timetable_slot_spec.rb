require 'spec_helper'
require 'roles/planned_timetable_slot'
require 'models/person'
require 'sirius/time_converter'
require 'sirius/event_planner'

describe PlannedTimetableSlot do

  describe '#generate_events' do

    let(:slot) { Fabricate(:timetable_slot, first_hour: 1, duration: 2, parity: :both, day: :monday) }
    let(:period) { Period.parse('7:30', '9:00') }
    let(:converter) { instance_double(Sirius::TimeConverter, convert_time: period) }
    let(:event_planner) { instance_double(Sirius::EventPlanner, plan: [period]) }
    subject(:planned_slot) { described_class.new(slot, converter, event_planner) }

    it 'converts Timetableslot to events' do
      events = planned_slot.generate_events
      expect(events.size).to be > 0
      expect(events.first).to be_an_instance_of(Event)
    end

  end

end
