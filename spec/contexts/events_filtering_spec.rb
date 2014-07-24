require 'spec_helper'
require 'events_filtering'

describe EventsFiltering do
  let(:dataset) {  }

  let(:dataset) do
    Sequel.mock.dataset.from(:test)
  end
  let(:context) { described_class.new(dataset) }

  let(:params) do
    {
      from: '2014-04-01',
      to: '2014-04-02',
      offset: 1,
      limit: 2,
    }
  end

  let(:format) { :jsonapi }
  let(:result) { context.call(params: params, format: format) }
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
