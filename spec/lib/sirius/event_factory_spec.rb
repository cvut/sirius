require 'spec_helper'
require 'sirius/event_factory'

describe Sirius::EventFactory do

  let(:parallel) { Fabricate(:parallel, capacity: 20) }
  let(:slot) { Fabricate(:timetable_slot, parallel: parallel) }
  let(:faculty_semester) { Fabricate.build(:faculty_semester) { code 'B141'; faculty 18_000 } }
  subject(:factory) { described_class.new(slot, faculty_semester) }
  let(:period) { Period.parse('7:30', '9:00') }

  it 'builds an Event from Period' do
    event = factory.build_event(period, 1)
    expect(event).to be_an_instance_of(Event)
  end

  it 'sets correct period values on generated Event' do
    event = factory.build_event(period, 1)
    expect(event.period).to eq period
  end

  it 'sets faculty and semester' do
    event = factory.build_event(period, 1)
    expect(event.faculty).to eq 18_000
    expect(event.semester).to eq 'B141'
  end

  it 'sets capacity from parallel' do
    event = factory.build_event(period, 1)
    expect(event.capacity).to eq 20
  end

end
