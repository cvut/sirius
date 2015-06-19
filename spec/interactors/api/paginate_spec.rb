require 'spec_helper'
require 'api/paginate'

describe Interactors::Api::Paginate do
  let(:db) { Sequel.mock(fetch: { count: 120, deleted: false }) }
  let(:dataset) { db.from(:test).columns(:count) }

  let(:params) do
    {
      offset: 1,
      limit: 2,
    }
  end

  subject(:interactor) { described_class.perform(dataset: dataset, params: params) }

  describe '#dataset' do
    let(:opts) { interactor.dataset.opts }

    context 'with default parameters' do
      let(:params) { Hash.new }
      it 'sets a default limit' do
        expect(opts[:limit]).to eql 20
      end
      it 'sets a zero offset' do
        expect(opts[:offset]).to eql 0
      end
    end

    context 'with passed parameters' do
      let(:params) do
        {
          offset: 1,
          limit: 2,
        }
      end
      it 'sets a passed limit' do
        expect(opts[:limit]).to eql 2
      end
      it 'sets a passed offset' do
        expect(opts[:offset]).to eql 1
      end
    end
  end

  describe '#count' do
    subject(:count) { interactor.count }
    it 'returns a total count of rows' do
      expect(count).to eq(120)
    end
  end

  describe '#meta' do
    subject(:meta) { interactor.meta }
    it { should be_a(Hash) }
    it { should have_only_keys(:count, :limit, :offset) }
  end
end
