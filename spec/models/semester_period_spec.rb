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

  describe '#validate' do
    context 'ends_at before starts_at' do
      let(:ends_at) { Date.new(1970, 1, 1)}
      it 'cannot create period with a start before end' do
        expect(period.valid?).to be false
      end
    end

    context 'with null parity' do
      let(:parity) { nil }

      [:holiday, :exams].each do |given_type|
        context "for #{given_type} period" do
          let(:type) { given_type }
          it 'accepts an empty first week parity' do
            expect(period.valid?).to be true
          end

        end
      end

      context 'for teaching period' do
        let(:type) { :teaching }
        it 'requires first week parity' do
          expect(period.valid?).to be false
        end
      end
    end
  end

  describe '#first_week_parity' do

    context 'with null period type' do
      let(:type) { :holiday }
      let(:parity) { nil }
      it 'can be nullable' do
        expect(period.save.reload.first_week_parity).to be nil
      end
    end
  end

end
