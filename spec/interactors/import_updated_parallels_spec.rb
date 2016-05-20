require 'spec_helper'
require 'interactors/import_updated_parallels'
require 'sirius/kosapi_client_registry'

describe ImportUpdatedParallels, :vcr do

  before do
    allow(Sirius::KOSapiClientRegistry.instance).to receive(:client_for_faculty)
      .and_return(create_kosapi_client)
  end

  describe '#perform' do

    let(:since) { Time.parse('1.7.2014') }
    let(:till) { Time.parse('10.7.2014') }
    let(:faculty_semester) { Fabricate.build(:faculty_semester) }

    it 'imports parallels' do
      expect do
        subject.perform(faculty_semester: faculty_semester, page_size: 10, fetch_all: false)
      end.to change(Parallel, :count).from(0)
    end

  end


end
