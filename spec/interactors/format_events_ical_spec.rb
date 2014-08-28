require 'spec_helper'
require 'format_events_ical'
require 'icalendar'
require 'models/event'

describe FormatEventsIcal do

  let(:event) { Fabricate.build(:event, id: 42, starts_at: '2014-04-05 14:30', ends_at: '2014-04-05 16:00') }
  let(:interactor) { described_class.perform(events: event) }
  let(:result) { interactor.ical }
  let(:calendar) { Icalendar.parse(result).first } # Parser returns array of calendars

  before { allow(event).to receive_messages(parallel: nil, name: nil, note: nil) }

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
      subject(:summary) { icevent.summary }
      context 'with an explicit name' do
        before { allow(event).to receive(:name).and_return('Groundhog day') }
        it 'uses the name as a summary' do
          expect(summary).to eql 'Groundhog day'
        end
      end

      context 'without an explicit name' do
        before do
          allow(event).to receive_messages(sequence_number: 3, course_id: 'MI-RUB', parallel: '101', event_type: 'tutorial')
        end
        it 'generates the name' do
          should eql 'MI-RUB 3. cvičení (101)'
        end
        pending 'event_type + locales'
      end
    end

    describe '#description' do
      subject(:description) { icevent.description }
      context 'with an explicit note' do
        before { allow(event).to receive(:note).and_return('Stomp the groundhogs!') }
        it 'uses the note as a description' do
          expect(description).to eql 'Stomp the groundhogs!'
        end
      end
      context 'without an explicit note' do
        let(:course) { double('Course', name: {'cs' => 'Programování v Ruby', 'en' => 'Programming in Ruby'}) }
        before do
          allow(event).to receive_messages(course: course, teacher_ids: ['vomackar'])
        end

        it 'generates the description' do
          expect(description).to eql 'Programování v Ruby'
        end
      end
    end

    describe '#uid' do

      subject(:uid) { icevent.uid }

      it { is_expected.to eq '42@example.com' }

    end

    [:dtstart, :dtend].each do |method|
      describe "##{method}" do
        it 'has a correct timezone' do
          expect(icevent.send(method).zone).to eql('CEST')
        end
      end
    end
  end
end
