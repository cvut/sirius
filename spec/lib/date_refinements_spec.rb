require 'spec_helper'
require 'rspec-parameterized'
require 'date_refinements'

describe DateRefinements do
  using RSpec::Parameterized::TableSyntax
  using described_class

  describe '#start_of_week' do

    where :date    , :expected do
      '2016-01-01' | '2015-12-28'
      '2016-01-04' | '2016-01-04'
      '2016-03-13' | '2016-03-07'
    end

    with_them ->{ date } do
      it "returns #{row.expected}" do
        expect( Date.parse(date).start_of_week ).to eq Date.parse(expected)
      end
    end
  end

  describe '#end_of_week' do

    where :date    , :expected do
      '2016-01-01' | '2016-01-03'
      '2016-01-10' | '2016-01-10'
      '2016-03-07' | '2016-03-13'
    end

    with_them ->{ date } do
      it "returns #{row.expected}" do
        expect( Date.parse(date).end_of_week ).to eq Date.parse(expected)
      end
    end
  end
end
