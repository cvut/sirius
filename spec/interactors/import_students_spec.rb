require 'spec_helper'
require 'interactors/import_students'
require 'sirius/kosapi_client_registry'

describe ImportStudents, :vcr do

  describe '#perform' do

    subject(:import) { described_class }
    let(:faculty_semester) { Fabricate.build(:faculty_semester) }

    before do
      allow(Sirius::KOSapiClientRegistry.instance).to receive(:client_for_faculty)
        .and_return(create_kosapi_client)
    end

    it 'updates parallel students' do
      parallel = Fabricate(:parallel, id: 339540000, semester: faculty_semester.code, faculty: faculty_semester.faculty)
      expect do
        import.perform(faculty_semester: faculty_semester)
        parallel.refresh
      end.to change(parallel, :student_ids).from(nil)
      expect(parallel.student_ids.count).to eq 15
      expect(Person.count).to eq 15
    end

  end

end
