require 'spec_helper'

describe Parallel do

  subject(:parallel) do
    par = Parallel.new
    par.timetable_slots = timetable_slots
    par
  end

  # let(:schedule_params) { { first_hour: Time.parse('7:30'), hour_length: 45, break_length: 15, break_after: 2 } }
  # let(:converter) { Sirius::TimeConverter.new(schedule_params) }
  let(:converter) { instance_double(Sirius::TimeConverter, convert_time: Sirius::Period.parse('7:30', '9:00')) }
  let(:event_planner) { instance_double(Sirius::EventPlanner, plan: Event.new(name: 'Foo', starts_at: Time.parse('7:30'), ends_at: Time.parse('9:00'))) }

  describe '#generate_events' do

    context 'when TimetableSlots are empty' do
      let(:timetable_slots) { [] }

      it 'outputs no events' do
        events = parallel.generate_events(converter, event_planner)
        expect(events).to eq([])
      end
    end

    context 'when TimetableSlots are not empty' do
      let(:timetable_slots) { [double('TimetableSlot', first_hour: 1, duration: 2, parity: :both, day: :monday)] }

      it 'converts Timetableslots to events' do
        events = parallel.generate_events(converter, event_planner)
        expect(events.size).to be > 0
        expect(events.first).to be_an_instance_of(Event)
      end
    end
  end





end
