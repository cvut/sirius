require 'spec_helper'
require 'interactors/fetch_students'

describe FetchStudents do

  subject { described_class[:exams, source_key: :exam_id, event_types: ['exam', 'assessment']].new }
  let(:kosapi_client) { spy }
  let(:faculty_semester) { Fabricate.build(:faculty_semester) }
  let(:kosapi_students) { [double(:student, full_name: 'Dude', username: 'skocdopet' ) ] }
  let(:exam) { Fabricate.build(:event, event_type: 'exam', source_type: 'exam', source_id: 42) }
  let!(:future_exam) { Fabricate(:event, event_type: 'exam', starts_at: Time.new + 1.hour,
    ends_at: Time.new + 2.hours, source_type: 'exam', source_id: 42) }

  before(:example) do
    subject.setup(client: kosapi_client)
  end

  describe '#perform' do

    it 'returns updated exam events' do
      allow(kosapi_client).to receive(:attendees).and_return(kosapi_students)
      subject.perform(faculty_semester: faculty_semester)
      events = subject.results[:events]
      expect(events).not_to be_empty
    end

    it 'returns associated students' do
      allow(kosapi_client).to receive(:attendees).and_return(kosapi_students)
      subject.perform(faculty_semester: faculty_semester)
      people = subject.results[:people]
      expect(people).not_to be_empty
    end

  end

  describe '#load_events' do

    it 'queries database for exams' do
      expect(Event).to receive(:where)
      subject.load_events(faculty_semester, false)
    end

    it 'loads only future exams when asked to' do
      past_exam = Fabricate(:event, event_type: 'exam', starts_at: Time.new - 2.hour, ends_at: Time.new - 1.hours)
      events = subject.load_events(faculty_semester, true)
      expect(events).to contain_exactly(future_exam)
    end

    it 'loads exams and assessments' do
      assessment = Fabricate(:event, event_type: :assessment)
      events = subject.load_events(faculty_semester, false)
      expect(events).to contain_exactly(future_exam, assessment)
    end

  end

  describe '#fetch_event_students' do

    it 'fetches event studennts from KOSapi' do
      subject.fetch_event_students(kosapi_client, exam)
      expect(kosapi_client).to have_received(:exams).ordered
      expect(kosapi_client).to have_received(:find).with(42).ordered
      expect(kosapi_client).to have_received(:attendees).ordered
    end

  end

  describe '#update_event_students' do

    it 'sets student ids to event' do
      subject.update_event_students(exam, kosapi_students)
      expect(exam.student_ids).to eq ['skocdopet']
    end

    it 'stores people info in results' do
      subject.update_event_students(exam, kosapi_students)
      person = subject.results[:people].first
      expect(person.id).to eq 'skocdopet'
    end
  end

end
