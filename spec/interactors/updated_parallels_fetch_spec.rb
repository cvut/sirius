require 'spec_helper'
require 'interactors/updated_parallels_fetch'
require 'sirius/updated_parallels_finder'

describe UpdatedParallelsFetch do

  let(:finder) { instance_double(Sirius::UpdatedParallelsFinder, find_updated: []) }
  subject(:fetch) { described_class.new }

  before { fetch.setup(finder: finder) }

  describe '#perform' do

    it 'retrieves updated parallels' do
      expect(finder).to receive(:find_updated)
      fetch.perform
    end

  end

end
