require 'spec_helper'
require 'actors/event_destination'

describe EventDestination do
  include ActorHelper

  let(:sync) { double(:sync, perform: nil, results: {}) }
  let(:events) { [double(:event) ]}
  subject(:actor) { described_class.new(nil, nil, sync).bare_object }

  describe '#process_row' do
    it 'synces given events' do
      expect(sync).to receive(:perform)
      actor.process_row(events)
    end

    it 'returns sync results' do
      allow(sync).to receive_message_chain(:results, :[]) { :events }
      expect(actor.process_row(events)).to be :events
    end
  end

  describe '#generate_row' do
    it 'raises EndOfData with no data' do
      expect { actor.generate_row }.to raise_error(EndOfData)
    end

    it 'outputs processed row once' do
      actor.processed_row = :foo
      expect(actor.generate_row).to be :foo
      expect { actor.generate_row }.to raise_error(EndOfData)
    end
  end
end
