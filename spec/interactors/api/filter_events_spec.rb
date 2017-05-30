require 'spec_helper'
require 'interactors/api/filter_events'

RSpec.shared_examples 'filtered by params' do
  subject(:sql) { events.sql }

  describe 'deleted record' do
    it 'filters cancelled and deleted events by default' do
      expect(sql).to include 'deleted IS FALSE'
      expect(sql).to_not include 'deleted IS TRUE'
    end
  end

  describe 'event type' do
    it 'is not used by default' do
      expect(sql).not_to include 'event_type'
    end

    context 'with event_type param set to true' do
      before { params[:event_type] = 'lecture' }
      it 'looks up only events of specified type' do
        expect(sql).to include "event_type = 'lecture'"
      end
    end
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
    it_behaves_like 'filtered by params'

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

    it_behaves_like 'filtered by params'

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
