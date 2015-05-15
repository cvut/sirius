require 'spec_helper'
require 'interactors/fetch_resource'

describe FetchResource, :vcr do

  context 'instance methods' do
    subject { described_class[:exams].new }
    let(:faculty_semester) { Fabricate.build(:faculty_semester) }
    let(:resource) { :exams }

    before do
      subject.setup(client: create_kosapi_client)
    end

    describe '#perform' do
      it 'fetches data from KOSapi' do
        subject.perform(faculty_semester: faculty_semester, limit: 100, paginate: false)
        expect(subject.results[:exams]).to be
      end
    end

    describe '#results' do
      it 'returns faculty_semester' do
        subject.perform(faculty_semester: faculty_semester, limit: 100, paginate: false)
        expect(subject.results[:faculty_semester]).to be faculty_semester
      end
    end
  end

  context 'class methods' do
    subject { described_class[:exams] }

    describe '.[]' do
      it 'creates new child class' do
        expect(subject).to be < described_class
      end

      it 'sets proper resource' do
        expect(subject.resource).to eq :exams
      end
    end
  end
end
