require 'spec_helper'
require 'api/represent_events_json'

describe Interactors::Api::RepresentEventsJson do

  let(:include_param) { 'teachers,courses' }
  let(:params) do
    {
      from: '2014-04-01',
      to: '2014-04-02',
      include: include_param,
    }
  end

  let(:include_student_ids) { true }

  subject(:interactor) do
    described_class.perform(events: dataset, params: params, include_student_ids: include_student_ids)
  end

  describe '#to_hash' do
    let(:events_cnt) { 5 }
    let(:teachers_cnt) { 2 }
    before do
      Fabricate.times(events_cnt, :full_event, students: 2, teachers: teachers_cnt)
    end

    let(:dataset) { Event.dataset }

    subject(:result) { interactor.to_hash }

    it { should be_a(Hash) }
    it { should include('meta', 'events') }

    describe 'response metadata' do
      subject(:meta) { result['meta'] }

      it 'has a total count of items' do
        expect(meta[:count]).to eq(events_cnt)
      end
    end

    describe 'linked resources' do
      subject(:linked) { result['linked'] }
      it { should have_only_keys('courses', 'teachers') }
      # Just preliminary heuristics, this should be further validated against spec
      %w{courses teachers}.each do |resource|
        describe resource do
          subject(:linked_resource) { linked[resource] }
          it { should_not be_empty }
          it { should have_at_least(1).item }
        end
      end

      context 'without single included param' do
        let(:include_param) { 'courses' }
        it 'omits the other one' do
          expect(linked).not_to include('teachers')
        end
      end

      context 'without included param' do
        let(:include_param) { nil }
        it 'omits linked resources completely' do
          expect(result).not_to include('linked')
        end
      end
    end

    describe 'event' do
      subject(:event) { result['events'].first }

      describe 'links.students' do
        subject { event['links']['students'] }

        context 'when include_student_ids: false' do
          let(:include_student_ids) { false }
          it { should be_nil }
        end

        context 'when include_student_ids: true' do
          let(:include_student_ids) { true }
          it { should_not be_empty }
        end
      end
    end
  end

end
