require 'spec_helper'
require 'actors/etl_producer'

describe ETLProducer do
  include ActorHelper

  subject(:actor) { sample_producer_actor.new }

  describe '#receive_eof' do
    it 'sends EOF to the output when finished' do
      second_actor = sample_consumer_actor.new
      actor.send(:output=, :out)
      Celluloid::Actor[:out] = second_actor
      expect(second_actor.bare_object).to receive(:receive_eof)
      actor.start!
      actor.receive_eof()
    end
  end
end
