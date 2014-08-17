require 'spec_helper'
require 'interactors/fetch_updated_parallels'
require 'sirius/updated_parallels_finder'

describe FetchUpdatedParallels do

  let(:finder) { instance_double(Sirius::UpdatedParallelsFinder, find_updated: []) }
  subject(:fetch) { described_class.new }

  before { fetch.setup(finder: finder) }

  describe '#perform' do

    it 'retrieves updated parallels' do
      expect(finder).to receive(:find_updated)
      fetch.perform
    end

    it 'accepts optional range parameters' do
      since = double(:since)
      till = double(:till)
      expect(finder).to receive(:find_updated).with(since, till)
      fetch.perform(last_updated_since: since, last_updated_till: till)
    end

  end

end
