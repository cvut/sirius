require 'spec_helper'
require 'filter_events'

RSpec.shared_examples 'filtered by params' do
  subject(:sql) { events.sql }
  describe 'deleted record' do
    it 'is filtered out by default' do
      expect(sql).to include 'deleted IS FALSE'
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


describe FilterEvents do
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
    describe 'paginates records' do
      it 'sets limit' do
        expect(result.limit).to eql(params[:limit])
      end

      it 'sets offset' do
        expect(result.offset).to eql(params[:offset])
      end
    end

    it_behaves_like 'filtered by params'
    context 'with deleted param set to true' do
      before { params[:deleted] = true }
      it 'filters out deleted events' do
        expect(events.sql).not_to include 'deleted'
      end
    end
  end

  context 'for ICal format' do
    let(:format) { :ical }
    it 'does not paginate records' do
      expect(result.limit).to be_nil
    end

    it_behaves_like 'filtered by params'
    context 'with deleted param set to true' do
      before { params[:deleted] = true }
      it 'always filters out deleted events' do
        expect(events.sql).to include 'deleted'
      end
    end
  end

  describe '#count' do

    it 'executes query on call' do
      expect_any_instance_of(Sequel::Dataset).to receive(:count).once
      result.count
    end

    describe 'generated query' do
      let(:deleted) { false }
      before do
        params[:deleted] = deleted
        result.count
      end
      subject(:sql) { db.sqls.first }
      it 'generates a single query' do
        expect(db.sqls.size).to eql 1
      end
      # FIXME: not really a best approach
      it 'is limited by date' do
        sqlfrag = "(starts_at >= '#{params[:from]}') AND (ends_at <= '#{params[:to]}')"
        expect(sql).to include sqlfrag
      end
      it 'is not limited by pagination' do
        expect(sql).to_not match(/offset/i)
      end
      it "doesn't count deleted events" do
        expect(sql).to include 'deleted IS FALSE'
      end

      context 'with deleted param' do
        let(:deleted) { true }
        it 'counts deleted items too' do
          expect(sql).to_not match(/deleted IS/i)
        end
      end
    end
  end

  describe '#to_h' do
    subject { result.to_h }

    it { should include(:events, :count, :offset => params[:offset], :limit => params[:limit]) }
  end
end
