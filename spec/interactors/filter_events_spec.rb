require 'spec_helper'
require 'filter_events'

describe FilterEvents do
  let(:db) { Sequel.mock(:fetch=>{:count=>120} ) }
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

  describe '#events' do
    subject { result.events }
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
  end

  context 'for ICal format' do
    let(:format) { :ical }
    it 'does not paginate records' do
      expect(result.limit).to be_nil
    end
  end

  describe '#count' do

    it 'executes query on call' do
      expect_any_instance_of(Sequel::Dataset).to receive(:count).once
      result.count
    end

    # FIXME: not really a best approach
    it 'is limited by date but not by pagination' do
      result.count
      expect(db.sqls).to eql ["SELECT count(*) AS count FROM test WHERE ((starts_at >= '#{params[:from]}') AND (ends_at <= '#{params[:to]}')) LIMIT 1"]
    end
  end
end
