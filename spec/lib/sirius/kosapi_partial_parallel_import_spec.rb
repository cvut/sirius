require 'spec_helper'
require 'sirius/kosapi_partial_parallel_import'

describe Sirius::KOSapiPartialParallelImport do

  let(:finder) { double(find_updated: []) }
  let(:client) { double(parallels: []) }
  subject(:import) { Sirius.KOSapiPartialParallelImport.new(client: client, finder: finder) }

  describe '#patial_update' do

    xit 'retrieves parallels from KOSapi' do
      expect(parallel_importer).to receive(:import_parallels)
      import.partial_update

    end

  end

end
