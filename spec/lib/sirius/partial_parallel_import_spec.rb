require 'spec_helper'
require 'sirius/partial_parallel_import'

describe Sirius::PartialParallelImport do

  let(:finder) { instance_double(Sirius::UpdatedParallelsFinder, find_updated: []) }
  subject(:import) { Sirius::PartialParallelImport.new(finder: finder) }

  describe '#run' do

    it 'retrieves updated parallels' do
      expect(finder).to receive(:find_updated)
      import.run
    end

  end

end
