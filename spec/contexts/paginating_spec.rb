require 'spec_helper'
require 'paginating'

describe Paginating do
  let(:dataset) { Sequel.mock.dataset.from(:test) }
  let(:context) { described_class.new(dataset) }

  context 'with default parameters' do
    # before( allow(dataset).to receive_message_chain() )
    subject { context.call().sql }
    it { should == 'SELECT * FROM test LIMIT 20 OFFSET 0'}
  end

  context 'with passed parameters' do
    subject { context.call(limit: 30, offset: 10) }
    it { should == 'SELECT * FROM test LIMIT 30 OFFSET 10'}
  end

end
