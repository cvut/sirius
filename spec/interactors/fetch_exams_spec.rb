require 'spec_helper'
require 'interactors/fetch_exams'

describe FetchExams, :vcr do

  subject { described_class.new }
  let(:faculty_semester) { Fabricate.build(:faculty_semester) }

  before do
    subject.setup(client: create_kosapi_client)
  end

  describe '#perform' do

    it 'fetches exams from KOSapi' do
      subject.perform(faculty_semester: faculty_semester, limit: 100, paginate: false)
      expect(subject.results[:exams]).to be
    end

  end

  describe '#results' do

    it 'returns faculty_semester' do
      subject.perform(faculty_semester: faculty_semester, limit: 100, paginate: false)
      expect(subject.results[:faculty_semester]).to be faculty_semester
    end

    it 'returns rooms' do
      subject.perform(faculty_semester: faculty_semester, limit: 100, paginate: false)
      expect(subject.results[:kosapi_rooms]).not_to be_empty
    end

  end
end
