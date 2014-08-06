require 'spec_helper'
require 'format_events_ical'
require 'icalendar'

describe FormatEventsIcal do

  let(:event) { Fabricate.build(:event) }
  let(:interactor) { described_class.perform(events: event) }
  let(:result) { interactor.ical }
  let(:calendar) { Icalendar.parse(result).first } # Parser returns array of calendars

  it 'formats an event to a string' do
    expect(result).to be_a(String)
  end

  it 'creates a valid icalendar string' do
    expect(calendar.events.size).to eq 1
  end
end
