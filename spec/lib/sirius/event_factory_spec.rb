require 'spec_helper'
require 'sirius/event_factory'

describe Sirius::EventFactory do

  let(:slot) { Fabricate(:timetable_slot) }
  subject(:factory) { described_class.new(slot) }
  let(:period) { Period.parse('7:30', '9:00') }

  it 'builds an Event from Period' do
    event = factory.build_event(period, 1)
    expect(event).to be_an_instance_of(Event)
  end

  it 'sets correct period values on generated Event' do
    event = factory.build_event(period, 1)
    expect(event.period).to eq period
  end


end
