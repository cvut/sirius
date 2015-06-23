require 'spec_helper'
require 'corefines'
require 'date_filtered_dataset'

describe DateFilteredDataset do
  subject(:role) { described_class.new(dataset) }
  let(:dataset) { Sequel.mock.dataset.from(:test) }

  describe '#filter_by_date' do

    subject { role.filter_by_date({from: from, to: to, with_original_date: with_original_date}).sql }
    let(:from) { nil }
    let(:to) { nil }
    let(:with_original_date) { false }

    context 'with no parameters' do
      subject { role.filter_by_date().sql }
      it { should == 'SELECT * FROM test'}
    end

    context 'with from' do
      let(:from) { Date.new(2014, 04, 01) }
      it { should == "SELECT * FROM test WHERE (starts_at >= '2014-04-01')"}

      context 'and with_original_date' do
        let(:with_original_date) { true }
        it { should == "SELECT * FROM test WHERE (starts_at >= '2014-04-01' OR original_starts_at >= '2014-04-01')" }
      end
    end

    context 'with to' do
      let(:to) { Date.new(2014, 04, 01) }
      it { should == "SELECT * FROM test WHERE (ends_at <= '2014-04-01')" }

      context 'and with_original_date' do
        let(:with_original_date) { true }
        it { should == "SELECT * FROM test WHERE (ends_at <= '2014-04-01' OR original_ends_at <= '2014-04-01')" }
      end
    end

    context 'with from and to' do
      let(:from) { Date.new(2014, 2, 3) }
      let(:to) { Date.new(2014, 04, 01) }

      it { should == "SELECT * FROM test WHERE ((starts_at >= '2014-02-03') AND (ends_at <= '2014-04-01'))" }

      context 'and with_original_date' do
        let(:with_original_date) { true }

        it do
          should == <<-SQL.gsub(/\s+/, ' ').strip
            SELECT * FROM test
            WHERE ((starts_at >= '2014-02-03' OR original_starts_at >= '2014-02-03')
              AND (ends_at <= '2014-04-01' OR original_ends_at <= '2014-04-01'))
          SQL
        end
      end
    end
  end

end
