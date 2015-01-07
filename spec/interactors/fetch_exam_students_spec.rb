require 'spec_helper'
require 'interactors/fetch_exam_students'

describe FetchExamStudents do

  subject { described_class.new }
  let(:kosapi_client) { spy }
  let(:faculty_semester) { Fabricate.build(:faculty_semester) }
  let(:kosapi_students) { [double(:student, full_name: 'Dude', username: 'skocdopet' ) ] }
  let(:exam) { Fabricate.build(:event, event_type: 'exam', source: {'exam_id' => 42}) }

  before(:example) do
    subject.setup(client: kosapi_client)
  end

  describe '#perform' do

    it 'returns updated exam events' do
      allow(Event).to receive(:where).and_return([exam])
      allow(kosapi_client).to receive(:attendees).and_return(kosapi_students)
      subject.perform(faculty_semester: faculty_semester)
      events = subject.results[:events]
      expect(events).not_to be_empty
    end

    it 'returns associated students' do
      allow(Event).to receive(:where).and_return([exam])
      allow(kosapi_client).to receive(:attendees).and_return(kosapi_students)
      subject.perform(faculty_semester: faculty_semester)
      people = subject.results[:people]
      expect(people).not_to be_empty
    end

  end

  describe '#load_exam_events' do

    it 'queries database for exams' do
      expect(Event).to receive(:where)
      subject.load_exam_events(faculty_semester)
    end

  end

  describe '#fetch_exam_students' do

    it 'fetches exam studennts from KOSapi' do
      subject.fetch_exam_students(kosapi_client, exam)
      expect(kosapi_client).to have_received(:exams).ordered
      expect(kosapi_client).to have_received(:find).with(42).ordered
      expect(kosapi_client).to have_received(:attendees).ordered
    end

  end

  describe '#update_exam_students' do
    
    it 'sets student ids to event' do
      subject.update_exam_students(exam, kosapi_students)
      expect(exam.student_ids).to eq ['skocdopet']
    end

    it 'stores people info in results' do
      subject.update_exam_students(exam, kosapi_students)
      person = subject.results[:people].first
      expect(person.id).to eq 'skocdopet'
    end
  end

end
