require 'spec_helper'
require 'period'

describe Period do
  describe '#parse' do

    it 'parses time values' do
      period = Period.parse('7:30', '9:00')
      expect(period.starts_at).to eq(Time.parse('7:30'))
      expect(period.ends_at).to eq(Time.parse('9:00'))
    end

    it 'parses date values' do
      period = Period.parse('11. 12. 2010', '15. 4. 2011')
      expect(period.starts_at).to eq(Time.parse('11. 12. 2010'))
      expect(period.ends_at).to eq(Time.parse('15. 4. 2011'))
    end

  end

  describe '#==' do

    it 'compares positively with equal instance' do
      period_a = Period.parse('11. 12. 2010', '15. 4. 2011')
      period_b = Period.parse('11. 12. 2010', '15. 4. 2011')
      expect(period_a == period_b).to be_truthy
    end

    it 'compares negatively with nonequal instance' do
      period_a = Period.parse('11. 12. 2010', '15. 4. 2011')
      period_b = Period.parse('11. 12. 2010', '16. 4. 2011')
      expect(period_a == period_b).to be_falsey
    end
  end

  describe '#include?' do

    subject(:period) { Period.parse('7:30', '9:00') }

    it 'includes itself' do
      expect(period).to include(period)
    end

    it 'includes period with start and end inside time range' do
      expect(period).to include(Period.parse('8:00', '8:30'))
    end

    it 'does not include period with start and end outside time range' do
      expect(period).not_to include(Period.parse('10:00', '12:00'))
    end

    it 'does not include crossing period' do
      expect(period).not_to include(Period.parse('8:00', '10:00'))
    end
  end

  describe '#cover?' do

    subject(:period) { Period.parse('7:30', '9:00') }

    it 'covers itself' do
      expect(period).to cover(period)
    end

    it 'covers period with start and end inside' do
      expect(period).to cover(Period.parse('8:00', '8:30'))
    end

    it 'does not cover period with start and end outside' do
      expect(period).not_to cover(Period.parse('10:00', '12:00'))
    end

    it 'covers crossing period' do
      expect(period).to cover(Period.parse('8:00', '10:00'))
    end
  end

end
