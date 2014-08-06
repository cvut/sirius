require 'spec_helper'
require 'parallel_from_kosapi'

describe ParallelFromKOSapi do

  describe '.from_kosapi' do
    let(:slots) { [] }
    let(:teachers) { [double(link_href: 'foo/szolatib', link_title: 'Bc. Tibor Szolár', link_id: 'szolatib')] }
    let(:course) { double( link_id: 'BI-AL2', link_title: 'English Language for IT' ) }
    let(:semester) { double( link_id: 'B132' )}
    let(:kosapi_parallel) { double(to_hash: {code: 1234, parallel_type: :tutorial}, link: double(link_href: 'foo/432', link_id: '432'), timetable_slots: slots, teachers: teachers, course: course, semester: semester) }

    it 'converts kosapi parallel to sirius paralell entity' do
      parallel = described_class.from_kosapi(kosapi_parallel)
      expect(parallel).to be_an_instance_of(Parallel)
      expect(parallel.code).to eq(1234)
    end

    it 'updates already existing parallel' do
      db_parallel = Fabricate(:parallel, id: 432)
      parallel = described_class.from_kosapi(kosapi_parallel)
      expect(parallel.id).to eq db_parallel.id
    end

    it 'loads teachers' do
      parallel = described_class.from_kosapi(kosapi_parallel)
      expect(parallel.teacher_ids).to eq(['szolatib'])
    end

    it 'stores new teacher record' do
      parallel = described_class.from_kosapi(kosapi_parallel)
      person = Person['szolatib']
      expect(person).not_to be_nil
      expect(person.full_name).to eq 'Bc. Tibor Szolár'
    end

    it 'uses already existing person record' do
      person = Fabricate(:person, id: 'szolatib', full_name: 'Bc. Tibor Szolár')
      parallel = described_class.from_kosapi(kosapi_parallel)
      expect(parallel.teacher_ids.first).to eq person.id
    end

    it 'loads course info' do
      parallel = described_class.from_kosapi(kosapi_parallel)
      expect(parallel.course.id).to eq 'BI-AL2'
      expect(parallel.course.name).to eq({'en' => 'English Language for IT'})
    end

    it 'saves new course record' do
      parallel = described_class.from_kosapi(kosapi_parallel)
      expect(parallel.course).not_to be_nil
      expect(parallel.course).to eq Course['BI-AL2']
    end

    it 'uses existing course record' do
      course = Fabricate(:course, id: 'BI-AL2', name: {'en' => 'English Language for IT'})
      parallel = described_class.from_kosapi(kosapi_parallel)
      expect(parallel.course).to eq course
    end

    it 'loads semester info' do
      parallel = described_class.from_kosapi(kosapi_parallel)
      expect(parallel.semester).to eq 'B132'
    end

    it 'loads parallel type info' do
      parallel = described_class.from_kosapi(kosapi_parallel)
      expect(parallel.parallel_type).to eq 'tutorial'
    end

  end

end

