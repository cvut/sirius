require 'interactors/convert_course_events'

describe ConvertCourseEvents do

  let(:self_link) { double(link_id: 42) }
  let(:course_event) { double(:course_event, start_date: Time.parse('11:00'), end_date: Time.parse('13:00'), capacity: 100, link: self_link ).as_null_object }
  let(:course_events) { [course_event] }
  let(:faculty_semester) { Fabricate.build(:faculty_semester) }

  describe '#perform' do

    it 'converts course events' do
      subject.perform(course_events: course_events, faculty_semester: faculty_semester)
      event = subject.results[:events].first
      expect(event.starts_at).to eq course_event.start_date
      expect(event.ends_at).to eq course_event.end_date
    end
  end

end
