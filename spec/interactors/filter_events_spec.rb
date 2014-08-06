require 'spec_helper'
require 'filter_events'

describe FilterEvents do
  let(:dataset) {  }

  let(:dataset) do
    Sequel.mock.dataset.from(:test)
  end
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
  let(:result) { interactor.perform(events: dataset, params: params, format: format).events }
  let(:opts) { result.opts }

  it 'returns a new dataset' do
    expect(result).to be_a(Sequel::Dataset)
  end

  context 'for JSON API format' do
    it 'paginates records' do
      expect(opts[:limit]).to eql(params[:limit])
    end
  end

  context 'for ICal format' do
    let(:format) { :ical }
    it 'does not paginate records' do
      expect(opts[:limit]).to be_nil
    end
  end
end
