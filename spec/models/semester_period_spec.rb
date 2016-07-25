require 'spec_helper'
require 'models/semester_period'
require 'rspec-parameterized'

describe SemesterPeriod do
  using RSpec::Parameterized::TableSyntax

  let(:starts_at) { Date.new(2015, 11, 11) }
  let(:ends_at) { Date.new(2016, 1, 13) }
  let(:type) { :teaching }
  let(:parity) { :odd }
  let(:semester) { Fabricate(:faculty_semester)}

  subject(:period) do
    described_class.new(starts_at: starts_at, ends_at: ends_at, type: type, first_week_parity: parity, faculty_semester: semester)
  end

  describe '#teaching?' do
    subject { period.teaching? }

    context 'teaching period' do
      it { should be true }
    end

    context 'non-teaching period' do
      let(:type) { :exams }
      it { should be false }
    end
  end

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

  describe '#include?' do

    context 'date in the range' do
      it 'returns true' do
        [starts_at, starts_at + 1, ends_at].each do |date|
          expect( period.include? date ).to be true
        end
      end
    end

    context 'date out of the range' do
      it 'returns false' do
        [starts_at - 1, ends_at + 1].each do |date|
          expect( period.include? date ).to be false
        end
      end
    end
  end

  describe '#week_parity' do
    let(:date) { Date.new(2015, 11, 13) }
    subject { period.week_parity(date) }

    context 'non-teaching period' do
      let(:type) { :exams }
      it { should be nil }
    end

    context 'date out of period' do
      ['2015-11-05', '2015-11-08', '2016-01-18', '2016-11-14'].each do |date|
        it "raises ArgumentError (#{date})" do
          expect { period.week_parity(Date.parse(date)) }.to raise_error(ArgumentError)
        end
      end
    end

    where :tdate   , :expected, :desc do
      '2015-11-11' | :odd     | 'first day of the period'
      '2015-11-09' | :odd     | 'date within the first week of the period, but before starts_at'
      '2015-12-01' | :even    | 'date in the fourth week of the period'
      '2016-01-07' | :odd     | 'date in the next year of the period'
    end

    with_them ->{ desc } do
      let(:date) { Date.parse(tdate) }

      it 'returns correct parity' do
        should eq expected
      end
    end
  end

end
