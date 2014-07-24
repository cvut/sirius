require 'spec_helper'
require 'paginated_dataset'

describe PaginatedDataset do
  subject(:role) { described_class.new(dataset) }
  let(:dataset) { Sequel.mock.dataset.from(:test) }

  describe '#paginate' do
    context 'with default parameters' do
      # before( allow(dataset).to receive_message_chain() )
      subject { role.paginate().sql }
      it { should == 'SELECT * FROM test LIMIT 20 OFFSET 0'}
    end

    context 'with passed parameters' do
      subject { role.paginate(limit: 30, offset: 10).sql }
      it { should == 'SELECT * FROM test LIMIT 30 OFFSET 10'}
    end
  end

end
