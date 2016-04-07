require 'spec_helper'
require 'actors/etl_actor'

describe ETLActor do
  include ActorHelper

  subject(:actor) { sample_actor_class.new }

  describe '#consume_row' do

    it 'calls #process_row' do
      expect(actor.bare_object).to receive(:process_row)
      actor.consume_row(:row)
    end
  end

  describe '#receive_eof' do
    it 'sends EOF to the output when finished' do
      second_actor = sample_actor_class.new
      actor.send(:set_output, :out)
      Celluloid::Actor[:out] = second_actor
      expect(second_actor.bare_object).to receive(:receive_eof)
      actor.receive_eof()
    end
  end
end
