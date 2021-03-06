require 'spec_helper'
require 'interactors/import_exams'

describe ImportExams, :vcr do

  subject { described_class }
  let(:faculty_semester) { Fabricate.build(:faculty_semester) }

  describe '#perform' do

    before { allow(Sirius::KOSapiClientRegistry.instance).to receive(:client_for_faculty) { create_kosapi_client } }

    it 'imports exams from KOSapi' do
      subject.perform(faculty_semester: faculty_semester, paginate: false)
    end

  end

end
