require 'spec_helper'
require 'sirius_api/date_or_date_time'

describe SiriusApi::DateOrDateTime do
  subject(:result) { described_class.parse(str) }

  context 'with date string' do
    let(:str) { '2015-10-14' }
    it { is_expected.to be_a(Date) }
  end

  context 'with date time string' do
    let(:str) { '2015-10-14T10:00:00' }
    it { is_expected.to be_a(DateTime) }
  end

  context 'with an invalid string' do
    let(:str) { 'loremipsum' }
    it 'raises an ArgumentError' do
      expect { result }.to raise_error(ArgumentError)
    end
  end
end
