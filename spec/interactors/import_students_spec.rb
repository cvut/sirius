require 'spec_helper'
require 'interactors/import_students'

describe ImportStudents, :vcr do

  describe '#perform' do

    subject(:import) { described_class }
    before { allow(KOSapiClient).to receive(:client) { create_kosapi_client } }

    it 'updates parallel students' do
      parallel = Fabricate(:parallel, id: 339540000)
      expect do
        import.perform
        parallel.refresh
      end.to change(parallel, :student_ids).from(nil)
      expect(parallel.student_ids.count).to eq 15
      expect(Person.count).to eq 15
    end

  end

end
