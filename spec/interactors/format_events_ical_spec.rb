require 'spec_helper'
require 'format_events_ical'
require 'icalendar'
require 'models/event'

describe FormatEventsIcal do

  let(:event) { Fabricate.build(:event, name: nil) }
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
    before { allow(event).to receive(:room).and_return('T9:350') }

    it "sets event's location to the room's code" do
      expect(icevent.location).to eql('T9:350')
    end

    describe '#summary' do
      subject { icevent.summary }
      context 'for an event with an explicit name' do
        before { allow(event).to receive(:name).and_return('Groundhog day') }
        it { should eql 'Groundhog day' }
      end

      context 'without an explicit name' do
        before do
          allow(event).to receive_messages(sequence_number: 3, course_id: 'MI-RUB', parallel: '101', event_type: 'whatevs')
        end
        it { should eql 'MI-RUB 3. (101)' }
        pending 'event_type + locales'
      end
    end
  end
end
