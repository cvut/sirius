require 'spec_helper'
require 'events_ical_formatting'
require 'icalendar'

describe EventsIcalFormatting do

  let(:event) { Fabricate.build(:event) }
  let(:context) { described_class.new(event) }
  let(:calendar) { Icalendar.parse(context.call).first } # Parser returns array of calendars

  it 'formats an event to a string' do
    expect(context.call).to be_a(String)
  end

  it 'creates a valid icalendar string' do
    expect(calendar.events.size).to eq 1
  end
end
