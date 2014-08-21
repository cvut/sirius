require 'spec_helper'
require 'models/parallel'
require 'models/person'
require 'sirius/time_converter'
require 'sirius/event_planner'

describe Parallel do

  subject(:parallel) do
    Parallel.new(code: 101).tap do |par|
      allow(par).to receive(:timetable_slots).and_return(timetable_slots)
    end
  end

  # let(:schedule_params) { { first_hour: Time.parse('7:30'), hour_length: 45, break_length: 15, break_after: 2 } }
  # let(:converter) { Sirius::TimeConverter.new(schedule_params) }
  let(:period) { Period.parse('7:30', '9:00') }
  let(:converter) { instance_double(Sirius::TimeConverter, convert_time: period) }
  let(:event_planner) { instance_double(Sirius::EventPlanner, plan: [period]) }
  let(:timetable_slots) { [] }

  describe '#generate_events' do

    context 'when TimetableSlots are empty' do
      it 'outputs no events' do
        events = parallel.generate_events(converter, event_planner)
        expect(events).to eq([])
      end
    end

    context 'when TimetableSlots are not empty' do
      let(:timetable_slots) { [TimetableSlot.new(first_hour: 1, duration: 2, parity: :both, day: :monday)] }

      it 'converts Timetableslots to events' do
        events = parallel.generate_events(converter, event_planner)
        expect(events.size).to be > 0
        expect(events.first).to be_an_instance_of(Event)
      end
    end
  end

  describe '#to_s' do
    it 'is aliased to a code' do
      expect(parallel.to_s).to eql '101'
    end
  end
end
