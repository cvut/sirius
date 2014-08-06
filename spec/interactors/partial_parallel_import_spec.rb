require 'spec_helper'
require 'interactors/partial_parallel_import'
require 'sirius/updated_parallels_finder'

describe PartialParallelImport do

  let(:finder) { instance_double(Sirius::UpdatedParallelsFinder, find_updated: []) }
  subject(:import) { PartialParallelImport.new }

  before { import.setup(finder: finder) }

  describe '#perform' do

    it 'retrieves updated parallels' do
      expect(finder).to receive(:find_updated)
      import.perform
    end

  end

end
