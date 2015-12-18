require 'spec_helper'
require 'sirius_api/semester_day'
require 'rspec-parameterized'

module SiriusApi
describe SemesterDay do

  using RSpec::Parameterized::TableSyntax

  let(:semester) do
    Fabricate.build :faculty_semester,
      id: 123,
      code: 'B151',
      faculty: 99000,
      starts_at: '2015-10-05',
      ends_at: '2016-02-21',
      semester_periods: semester_periods
  end

  let(:semester_periods) do
    [# type,      starts_at,    ends_at,      parity, day_override
      [:teaching, '2015-10-05', '2015-12-07', :odd,   nil],
      [:teaching, '2015-12-08', '2015-12-09', :odd,   :thursday],
      [:teaching, '2015-12-10', '2015-12-21', :even,  nil],
      [:teaching, '2015-12-22', '2015-12-22', :odd,   nil],
      [:holiday,  '2015-12-23', '2016-01-03', nil,    nil],
      [:teaching, '2016-01-04', '2016-01-10', :even,  nil],
      [:exams,    '2016-01-11', '2016-02-21', nil,    nil]
    ].map do |row|
      Fabricate.build :semester_period,
        type: row[0],
        starts_at: row[1],
        ends_at: row[2],
        first_week_parity: row[3],
        first_day_override: row[4]
    end
  end

  subject(:sem_day) { described_class.new(semester, date) }
  let(:date) { Date.parse '2015-12-11' }


  describe '.resolve' do

    subject { described_class.resolve(date, faculty) }
    let(:faculty) { 18000 }

    before do
      expect(FacultySemester).to receive(:find_by_date)
        .with(date, faculty).and_return(semester)
    end

    context 'unknown faculty or date' do
      let(:semester) { nil }
      it { should be_nil }
    end

    context 'valid arguments' do
      it { should be_instance_of SemesterDay }

      it 'finds semester for the given date' do
        expect( subject.semester ).to eq semester
      end
    end
  end

  describe '#date' do
    it 'returns frozen object' do
      expect( sem_day.date.frozen? ).to be true
    end
  end

  describe '#semester' do
    it 'returns frozen object' do
      expect( sem_day.semester.frozen? ).to be true
    end
  end

  describe '#period' do
    it 'returns correct period' do
      expect( sem_day.period ).to eq semester_periods[2]
    end
  end

  describe '#cwday/#wday_name' do

    context 'for normal day' do
      it "returns a calendar week day" do
        expect( sem_day.cwday ).to eq 5
        expect( sem_day.wday_name ).to eq :friday
      end
    end

    context 'for date affected by first_day_override' do
      let(:date) { Date.parse '2015-12-08' }

      it 'returns a week day shifted by first_day_override' do
        expect( sem_day.cwday ).to eq 4
        expect( sem_day.wday_name ).to eq :thursday
      end
    end
  end

  describe '#week_parity' do

    where :tdate   , :expected, :desc do
      '2015-10-05' | :odd     | 'first day of teaching period'
      '2015-10-12' | :even    | 'day a week after start of teaching period'
      '2015-12-08' | :odd     | 'first day of new teaching period with flipped parity'
      '2016-01-10' | :even    | 'last day of last teaching period'
      '2015-12-24' | nil      | 'holiday period'
      '2016-01-12' | nil      | 'exams period'
    end

    with_them ->{ desc } do
      let(:date) { Date.parse tdate }

      it 'returns correct parity' do
        expect( sem_day.week_parity ).to eq expected
      end
    end
  end

  describe '#week_num' do

    where :tdate   , :expected, :desc do
      '2015-10-05' | 1        | 'first day of first teaching period'
      '2015-12-22' | 12       | 'day before holiday in same week'
      '2015-12-23' | 1        | 'first day of holiday after teaching period'
      '2016-01-04' | 13       | 'week in a teaching period after holidays'
      '2016-01-24' | 2        | 'second week of exams period'
    end

    with_them ->{ desc } do
      let(:date) { Date.parse tdate }

      it 'returns correct week number' do
        expect( sem_day.week_num ).to eq expected
      end
    end
  end
end
end
