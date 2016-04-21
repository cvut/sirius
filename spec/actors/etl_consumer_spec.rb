require 'spec_helper'
require 'actors/etl_consumer'

describe ETLConsumer do
  include ActorHelper

  subject(:actor) { sample_consumer_actor.new }

  describe '#consume_row' do

    it 'calls #process_row' do
      actor.start!
      expect(actor.bare_object).to receive(:process_row)
      actor.consume_row(:row)
    end
  end

end
