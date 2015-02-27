require 'interactors/import_course_events'

describe ImportCourseEvents, :vcr do

  subject { described_class }
  let(:faculty_semester) { Fabricate.build(:faculty_semester) }

  describe '#perform' do
    before { allow(Sirius::KOSapiClientRegistry.instance).to receive(:client_for_faculty) { create_kosapi_client } }

    it 'imports course events from KOSapi' do
      expect {
        subject.perform(faculty_semester: faculty_semester, paginate: false)
      }.to change(Event, :count).from(0)
    end
  end

end
