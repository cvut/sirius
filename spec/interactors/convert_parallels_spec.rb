require 'spec_helper'
require 'interactors/convert_parallels'

describe ConvertParallels do

  subject(:convert) { described_class }

  describe '#perform' do

    context 'when parallels empty' do
      it 'returns empty result' do
        results = convert.perform(kosapi_parallels: []).results
        expect(results).to eq({parallels: [], timetable_slots: {}, people: [], courses: []})
      end
    end

    context 'with parallels' do

      let(:slot) { double(:slot) }
      let(:teacher) { double(:teacher, link_id: 'vomackar', link_title: 'Ing. Karel Vomáčka CSc.') }
      let(:parallel_attrs) { {id: 239018, parallel_type: :lecture, code: 1234, capacity: 50, occupied: 10} }
      let(:course) { double(:course, link_id: 'BI-ZUM', link_title: 'Course title') }
      let(:semester) { double(:semester, link_id: 'B102') }
      let(:parallel) { double(:kosapi_parallel, to_hash: parallel_attrs, link: double(link_id: '239018'), semester: semester, course: course, timetable_slots: [slot], teachers: [teacher]) }

      it 'converts parallels' do
        results = convert.perform(kosapi_parallels: [parallel]).results
        parallel = results[:parallels].first
        expect(parallel.parallel_type).to eq 'lecture'
        expect(parallel.code).to eq 1234
        expect(parallel.capacity).to eq 50
        expect(parallel.occupied).to eq 10
        expect(parallel.id).to eq 239018
      end

      it 'extracts courses' do
        results = convert.perform(kosapi_parallels: [parallel]).results
        parallel = results[:parallels].first
        course = results[:courses].first
        expect(parallel.course_id).to eq course.id
        expect(course.id).to eq 'BI-ZUM'
        expect(course.name).to eq({'cs' => 'Course title'})
      end

      it 'extracts people' do
        results = convert.perform(kosapi_parallels: [parallel]).results
        parallel = results[:parallels].first
        person = results[:people].first
        expect(parallel.teacher_ids).to eq ['vomackar']
        expect(person.id).to eq 'vomackar'
        expect(person.full_name).to eq 'Ing. Karel Vomáčka CSc.'
      end

      it 'collect slots' do
        results = convert.perform(kosapi_parallels: [parallel]).results
        parallel = results[:parallels].first
        expect(results[:timetable_slots]).to eq({'239018' => [slot]})
      end

    end

  end

end
