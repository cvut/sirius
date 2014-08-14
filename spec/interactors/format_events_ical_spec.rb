require 'spec_helper'
require 'format_events_ical'
require 'icalendar'

describe FormatEventsIcal do

  let(:room) { Fabricate(:room, kos_code: 'T9:350') }
  let(:event) { Fabricate.build(:event, room: room) }
  let(:interactor) { described_class.perform(events: event) }
  let(:result) { interactor.ical }
  let(:calendar) { Icalendar.parse(result).first } # Parser returns array of calendars

  it 'formats an event to a string' do
    expect(result).to be_a(String)
  end

  it 'creates a valid icalendar string' do
    expect(calendar.events.size).to eq 1
  end

  describe 'generated ICalendar event' do
    subject(:icevent) { calendar.events.first }

    it "sets event's location to the room's code" do
      expect(icevent.location).to eql('T9:350')
    end
  end
end
