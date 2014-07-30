require 'spec_helper'
require 'models/parallel'
require 'models/person'

describe Parallel do

  subject(:parallel) do
    parallel = Parallel.new
    allow(parallel).to receive(:timetable_slots).and_return(timetable_slots)
    parallel
  end

  # let(:schedule_params) { { first_hour: Time.parse('7:30'), hour_length: 45, break_length: 15, break_after: 2 } }
  # let(:converter) { Sirius::TimeConverter.new(schedule_params) }
  let(:period) { Period.parse('7:30', '9:00') }
  let(:converter) { instance_double(Sirius::TimeConverter, convert_time: period) }
  let(:event_planner) { instance_double(Sirius::EventPlanner, plan: [period]) }

  describe '#generate_events' do

    context 'when TimetableSlots are empty' do
      let(:timetable_slots) { [] }

      it 'outputs no events' do
        events = parallel.generate_events(converter, event_planner)
        expect(events).to eq([])
      end
    end

    context 'when TimetableSlots are not empty' do
      let(:timetable_slots) { [TimetableSlot.new(first_hour: 1, duration: 2, parity: :both, day: :monday)] }

      it 'converts Timetableslots to events' do
        events = parallel.generate_events(converter, event_planner)
        expect(events.size).to be > 0
        expect(events.first).to be_an_instance_of(Event)
      end
    end
  end

  describe '.from_kosapi' do
    let(:slots) { [] }
    let(:teachers) { [double(link_href: 'foo/szolatib', link_title: 'Bc. Tibor Szolár', link_id: 'szolatib')] }
    let(:course) { double( link_id: 'BI-AL2', link_title: 'English Language for IT' ) }
    let(:semester) { double( link_id: 'B132' )}
    let(:kosapi_parallel) { double(to_hash: {code: 1234, parallel_type: :tutorial}, link: double(link_href: 'foo/432', link_id: '432'), timetable_slots: slots, teachers: teachers, course: course, semester: semester) }

    it 'converts kosapi parallel to sirius paralell entity' do
      parallel = Parallel.from_kosapi(kosapi_parallel)
      expect(parallel).to be_an_instance_of(Parallel)
      expect(parallel.code).to eq(1234)
    end

    it 'updates already existing parallel' do
      db_parallel = Fabricate(:parallel, id: 432)
      parallel = Parallel.from_kosapi(kosapi_parallel)
      expect(parallel.id).to eq db_parallel.id
    end

    it 'loads teachers' do
      parallel = Parallel.from_kosapi(kosapi_parallel)
      expect(parallel.teacher_ids).to eq(['szolatib'])
    end

    it 'stores new teacher record' do
      parallel = Parallel.from_kosapi(kosapi_parallel)
      person = Person['szolatib']
      expect(person).not_to be_nil
      expect(person.full_name).to eq 'Bc. Tibor Szolár'
    end

    it 'uses already existing person record' do
      person = Fabricate(:person, id: 'szolatib', full_name: 'Bc. Tibor Szolár')
      parallel = Parallel.from_kosapi(kosapi_parallel)
      expect(parallel.teacher_ids.first).to eq person.id
    end

    it 'loads course info' do
      parallel = Parallel.from_kosapi(kosapi_parallel)
      expect(parallel.course.id).to eq 'BI-AL2'
      expect(parallel.course.name).to eq({'en' => 'English Language for IT'})
    end

    it 'saves new course record' do
      parallel = Parallel.from_kosapi(kosapi_parallel)
      expect(parallel.course).not_to be_nil
      expect(parallel.course).to eq Course['BI-AL2']
    end

    it 'uses existing course record' do
      course = Fabricate(:course, id: 'BI-AL2', name: {'en' => 'English Language for IT'})
      parallel = Parallel.from_kosapi(kosapi_parallel)
      expect(parallel.course).to eq course
    end

    it 'loads semester info' do
      parallel = Parallel.from_kosapi(kosapi_parallel)
      expect(parallel.semester).to eq 'B132'
    end

    it 'loads parallel type info' do
      parallel = Parallel.from_kosapi(kosapi_parallel)
      expect(parallel.parallel_type).to eq 'tutorial'
    end

  end

end
