require 'spec_helper'
require 'roles/page_meta'

describe PageMeta do

  let(:wrapped) { [1, 2, 3] }
  let(:page_meta) { {offset: 2, limit: 5, count: 3} }
  subject(:paged) { described_class.new(wrapped, **page_meta) }

  it 'wraps the given object and sets page_meta' do
    expect( paged ).to eq wrapped
    expect( paged.page_meta ).to eq page_meta
  end

  context 'with incomplete arguments' do
    let(:page_meta) { {offset: 0} }

    it 'raises an error' do
      expect{ paged }.to raise_error(ArgumentError)
    end
  end
end
