require 'spec_helper'
require 'api/compound_events'

describe Interactors::Api::CompoundEvents do
  let(:db) { Sequel.mock(fetch: { count: 120, deleted: false }) }
  let(:dataset) { db.from(:test).columns(:count) }

  let(:include_param) { 'lorem,ipsum,courses,,,pigeons,teachers' }
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

  describe '#joins' do
    subject { interactor.joins(include_param) }
    it { should be_a(Set) }
    it { should contain_exactly('courses', 'teachers') }

    context 'with empty object' do
      let(:include_param) { nil }
      it { should be_a(Set) }
      it { should be_empty }
    end
  end

  describe '#courses' do
    subject(:courses) { interactor.courses }

    it { should be_a(Sequel::Dataset) }
    it 'selects id and name' do
      expect(courses.columns).to eq([:id, :name])
    end
    it 'selects from courses' do
      expect(courses.first_source_table).to eq(:courses)
    end
  end

  describe '#teachers' do
    subject(:teachers) { interactor.teachers }
    it { should be_a(Sequel::Dataset) }

    it "selects person's id and name" do
      expect(teachers.columns).to eq([:id, :full_name])
    end

    it 'selects from people' do
      expect(teachers.first_source_table).to eq(:people)
    end
  end

  describe '#compounds' do
    subject { interactor.compounds }

    it { should have_only_keys(:courses, :teachers) }

    context 'without any compound params' do
      let(:include_param) { nil }

      it { should eq({}) }
    end

  end

end
