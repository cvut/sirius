require 'spec_helper'
require 'interactors/convert_exams'

describe ConvertExams do

  subject { described_class }
  let(:course) { double(link_id: 'BI-ZUM', link_title: 'Sample course') }
  let(:kosapi_room) { double(link_id: 'T9:105') }
  let(:kosapi_rooms) { [kosapi_room]}
  let(:teacher) { double(link_id: 'kordikp', link_title: 'Ing. Pavel Kordík Ph.D.') }
  let(:exam) { double(:exam, link: double(link_id: 620283180005), start_date: Time.parse('2015-01-12T11:00:00'), end_date: Time.parse('2015-01-12T12:00:00'),
                      capacity: 10, course: course, room: kosapi_room, examiner: teacher, term_type: :final_exam)}
  let(:exams) { [exam] }
  let(:faculty_semester) { Fabricate.build(:faculty_semester) }
  let(:rooms) { [Fabricate.build(:room, id: 42, kos_code: 'T9:105')] }

  describe '#perform' do

    it 'converts exams to events' do
      instance = subject.perform(exams: exams, faculty_semester: faculty_semester, rooms: rooms)
      events = instance.results[:events]
      event = events.first
      expect(events).to be
      expect(event.starts_at).to eq Time.parse('2015-01-12T11:00:00')
      expect(event.ends_at).to eq Time.parse('2015-01-12T12:00:00')
      expect(event.course_id).to eq 'BI-ZUM'
      expect(event.teacher_ids).to eq ['kordikp']
      expect(event.capacity).to eq 10
      expect(event.event_type).to eq 'exam'
      expect(event.semester).to eq 'B141'
      expect(event.faculty).to eq 18000
      expect(event.source).to eq(Sequel.hstore({ exam_id: 620283180005 }))
    end

    it 'outputs people' do
      instance = subject.perform(exams: exams, faculty_semester: faculty_semester, rooms: rooms)
      people = instance.results[:people]
      person = people.first
      expect(person.full_name).to eq 'Ing. Pavel Kordík Ph.D.'
      expect(person.id).to eq 'kordikp'
    end

    it 'outputs courses' do
      instance = subject.perform(exams: exams, faculty_semester: faculty_semester, rooms: rooms)
      courses = instance.results[:courses]
      course = courses.first
      expect(course.id).to eq 'BI-ZUM'
      expect(course.name).to eq({'cs' => 'Sample course'})
    end

    context 'with no examiner' do

      let(:teacher) { nil }

      it 'sets empty teacher_ids array' do
        instance = subject.perform(exams: exams, faculty_semester: faculty_semester, rooms: rooms)
        events = instance.results[:events]
        event = events.first
        expect(event.teacher_ids).to eq []
      end

    end

    context 'with missing end time' do

      let(:exam) { double(:exam, link: double(link_id: 620283180005), start_date: Time.parse('2015-01-12T11:00:00'), end_date: nil,
                      capacity: 10, course: course, room: kosapi_room, examiner: teacher, term_type: :final_exam)}

      it 'sets default duration of 90 minutes' do
        instance = subject.perform(exams: exams, faculty_semester: faculty_semester, rooms: rooms)
        events = instance.results[:events]
        event = events.first
        expect(event.ends_at).to eq(event.starts_at + 90.minutes)
      end

    end

    context 'with assessment instead of exam' do
       let(:exam) { create_exam(term_type: :assessment) }

       it 'sets event type as assessment' do
         instance = subject.perform(exams: exams, faculty_semester: faculty_semester, rooms: rooms)
         events = instance.results[:events]
         event = events.first
         expect(event.event_type).to eq 'assessment'
       end

    end

  end

  def create_exam(end_date: Time.parse('2015-01-12T12:00:00'), term_type: :final_exam)
    double(:exam,
     link: double(link_id: 620283180005),
     start_date: Time.parse('2015-01-12T11:00:00'),
     end_date: end_date,
     capacity: 10, course: course, room: kosapi_room, examiner: teacher, term_type: term_type)
  end

end

