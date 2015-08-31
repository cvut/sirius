require 'spec_helper'
require 'models/semester_period'

describe SemesterPeriod do

  let(:starts_at) { Date.new(2015, 10, 6) }
  let(:ends_at) { Date.new(2015, 12, 20) }
  let(:type) { :teaching }
  let(:parity) { :odd }
  subject(:period) {
    described_class.new(starts_at: starts_at, ends_at: ends_at, type: type, first_week_parity: parity)
  }

  describe 'validations' do
    it 'cannot create period with a start before end' do

    end

    it 'requires first week parity for teaching type' do

    end
  end

  describe '#first_week_parity' do

    context 'with null period type' do
      let(:parity) { nil }
      it 'can be nullable' do
        expect(period.save.reload.first_week_parity).to be nil
      end
    end
  end

end
