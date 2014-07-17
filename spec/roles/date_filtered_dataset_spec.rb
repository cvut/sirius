require 'spec_helper'
require 'date_filtered_dataset'

describe DateFilteredDataset do
  subject(:role) { described_class.new(dataset) }
  let(:dataset) { Sequel.mock.dataset.from(:test) }

  describe '#filter_by_date' do
    context 'with no parameters' do
      subject { role.filter_by_date().sql }
      it { should == 'SELECT * FROM test'}
    end

    context 'with from' do
      subject { role.filter_by_date(from: Date.new(2014, 04, 01)).sql }
      it { should == "SELECT * FROM test WHERE (starts_at >= '2014-04-01')"}
    end

    context 'with to' do
      subject { role.filter_by_date(to: Date.new(2014, 04, 01)).sql }
      it { should == "SELECT * FROM test WHERE (ends_at <= '2014-04-01')" }
    end

    context 'with from and to' do
      subject { role.filter_by_date(from: DateTime.new(2014, 2, 3), to: Date.new(2014, 04, 01)).sql }
      it { should == "SELECT * FROM test WHERE (starts_at >= '2014-02-03') AND (ends_at <= '2014-04-01')" }
    end
  end

end
