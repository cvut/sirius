require 'spec_helper'
require 'paginated_dataset'

describe PaginatedDataset do
  let(:dataset) { Sequel.mock.dataset.from(:test) }
  subject(:role) { described_class.new(dataset) }

  describe '#paginate' do
    it 'returns an instance of self' do
      expect(role.paginate).to be_a(described_class)
    end

    context 'with default parameters' do
      # before( allow(dataset).to receive_message_chain() )
      subject(:opts) { role.paginate.opts }
      it 'sets a default limit' do
        expect(opts[:limit]).to eql 20
      end
      it 'sets a zero offset' do
        expect(opts[:offset]).to eql 0
      end
    end

    context 'with passed parameters' do
      subject { role.paginate(limit: 30, offset: 10).sql }
      it { should == 'SELECT * FROM test LIMIT 30 OFFSET 10'}
    end
  end

end
