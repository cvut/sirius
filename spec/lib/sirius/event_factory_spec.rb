require 'spec_helper'

describe Sirius::EventFactory do

  subject(:factory) { Sirius::EventFactory.new }
  let(:period) { Sirius::Period.parse('7:30', '9:00') }

  it 'builds an Event from Period' do
    event = factory.build_event(period)
    expect(event).to be_an_instance_of(Event)
  end

  it 'sets correct period values on generated Event' do
    event = factory.build_event(period)
    expect(event.period).to eq period
  end




end