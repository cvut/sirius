require 'spec_helper'
require 'api/represent_events_json'

describe Interactors::Api::RepresentEventsJson do
  let(:db) { Sequel.mock(fetch: { count: 120, deleted: false }) }
  let(:dataset) { db.from(:test).columns(:count) }

  let(:include_param) { 'teachers,courses' }
  let(:params) do
    {
      from: '2014-04-01',
      to: '2014-04-02',
      offset: 1,
      limit: 2,
      include: include_param,
    }
  end

  subject(:interactor) { described_class.perform(events: dataset, params: params) }

  describe '#as_json' do
    before do
      Fabricate.times(5, :full_event)
    end

    let(:dataset) { Event.dataset }

    subject(:result) { interactor.as_json }

    it { should be_a(Hash) }


    it { should include('meta', 'events') }

    describe 'response metadata' do
      subject(:meta) { result['meta'] }

      it 'has a total count of items' do
        expect(meta[:count]).to eq(5)
      end
    end

    describe 'linked resources' do
      subject(:linked) { result['linked'] }
      it { should include('courses', 'teachers') }
      %w{courses teachers}.each do |resource|
        describe resource do
          subject { linked[resource] }
          it { should_not be_empty }
        end
      end



    end

  end

end
