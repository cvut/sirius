require 'spec_helper'
require 'interactors/fetch_exams'

describe FetchExams do

  subject { described_class }
  let(:faculty_semester) { Fabricate.build(:faculty_semester) }

  describe '#perform' do

    it 'fetches exams from KOSapi' do
      instance = subject.perform(faculty_semester: faculty_semester)
      expect(instance.results[:exams]).to be
    end

  end

  describe '#results' do

    it 'returns faculty_semester' do
      instance = subject.perform(faculty_semester: faculty_semester)
      expect(instance.results[:faculty_semester]).to be faculty_semester
    end

  end
end
