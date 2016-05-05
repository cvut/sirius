require 'spec_helper'
require 'actors/etl_producer'

describe ETLProducer do
  include ActorHelper

  subject(:actor) { sample_producer_actor.new.bare_object }

  describe '#receive_eof' do
    it 'sends EOF to the output when finished' do
      expect(actor).to receive(:emit_eof)
      actor.start!
      actor.receive_eof()
    end
  end

  describe '#produce_row' do
    it 'outputs a row when not empty' do
      allow(actor).to receive(:generate_row) { :foo }
      expect(actor).to receive(:output_row)
      actor.produce_row
    end

    it 'marks empty when there are no data to generate' do
      expect(actor).to receive(:mark_empty!)
      actor.produce_row
    end
  end

  describe '#output_row' do
    it 'emits the row directly when output is hungry' do
      actor.receive_hungry
      expect(actor).to receive(:emit_row)
      actor.output_row(:foo)
    end

    it 'buffers the row when output is stuffed' do
      expect(actor).to receive(:buffer_put)
      actor.output_row(:foo)
    end
  end

  describe '#emit_row' do
    it 'sends row to the output asynchronously' do
      expect(Celluloid::Actor).to receive_message_chain(:[], :async, :consume_row).with(:foo)
      actor.emit_row(:foo)
    end
  end

  describe '#receive_hungry' do
    before do
      allow(actor).to receive(:emit_row)
      actor.buffer_put(:foo)
    end

    it 'emits row from buffer when buffer not empty' do
      expect(actor).to receive(:emit_row).with(:foo)
      actor.receive_hungry
    end

    it 'produces a row after emitting' do
      expect(actor).to receive(:produce_row)
      actor.receive_hungry
    end
  end
end
