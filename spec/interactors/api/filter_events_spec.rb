require 'spec_helper'
require 'interactors/api/filter_events'

RSpec.shared_examples 'filtered by params' do
  subject(:sql) { events.sql }

  context 'when deleted param is not set' do
    it 'filters out cancelled and deleted events' do
      expect(sql).to include 'deleted IS FALSE'
      expect(sql).to_not include 'deleted IS TRUE'
    end
  end

  context 'when event_type param is not set' do
    it 'does not filter events by type' do
      expect(sql).not_to include 'event_type'
    end
  end

  %w[assessment course_event exam laboratory lecture tutorial].each do |value|
    context "with event_type param set to '#{value}'" do
      before { params[:event_type] = value }

      it 'looks up only events of specified type' do
        expect(sql).to include "event_type = '#{value}'"
      end
    end
  end
end

RSpec.shared_examples 'sorted' do
  subject(:sql) { events.sql }

  it 'sorts events by starts_at and id' do
    expect(events.sql).to include ' ORDER BY starts_at, id'
  end
end


describe Interactors::Api::FilterEvents do
  let(:db) { Sequel.mock(fetch: { count: 120, deleted: false }) }
  let(:dataset) { db.from(:test).columns(:count) }

  let(:interactor) { described_class }

  let(:params) do
    {
      from: '2014-04-01',
      to: '2014-04-02',
      offset: 1,
      limit: 2,
    }
  end

  let(:format) { :jsonapi }
  subject(:result) { interactor.perform(events: dataset, params: params, format: format) }
  let(:events) { result.events }

  describe '#events' do
    subject { events }
    it { should be_a(Sequel::Dataset) }
  end

  context 'for JSON API format' do
    include_examples 'filtered by params'
    it_behaves_like 'sorted'

    context 'with deleted param set to true' do
      before { params[:deleted] = 'true' }

      it 'filters out cancelled events' do
        expect(events.sql).to include \
          'deleted IS FALSE OR deleted IS TRUE AND applied_schedule_exception_ids IS NOT NULL'
      end
    end

    context 'with deleted param set to all' do
      before { params[:deleted] = 'all' }

      it 'does not filter cancelled and deleted events' do
        expect(events.sql).to_not match /\bdeleted\b/i
      end
    end
  end

  context 'for ICal format' do
    let(:format) { :ical }

    include_examples 'filtered by params'
    it_behaves_like 'sorted'

    ['true', 'all'].each do |value|
      context "with deleted param set to #{value}" do
        before { params[:deleted] = value }

        it 'always filters out cancelled and deleted events' do
          expect(events.sql).to match 'deleted IS FALSE'
        end
      end
    end
  end

  describe '#to_h' do
    subject { result.to_h }

    it { should include(:events) }
  end

  describe '#coerce_param_deleted' do
    subject(:result) { interactor.new.send(:coerce_param_deleted, input) }

    %w[false FALSE no NO off OFF f F n N 0].each do |input|
      context "with '#{input}'" do
        let(:input) { input }
        it { should be false }
      end
    end

    %w[true TRUE yes YES on ON t T y Y 1].each do |input|
      context "with '#{input}'" do
        let(:input) { input }
        it { should be true }
      end
    end

    context "with 'all'" do
      let(:input) { 'all' }
      it { should be :all }
    end
  end
end
