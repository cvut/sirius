require 'spec_helper'
require 'corefines'
require 'rspec-parameterized'
require 'sirius_api/semester_week'

describe SiriusApi::SemesterWeek do
  using Corefines::Enumerable::index_by
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

  # This is input for the .resolve_weeks method.
  let(:semester_periods) do
    [# type     , starts_at   , ends_at     , parity, day_override, irregular # semester_week_idx
      ['teaching', '2015-12-03', '2015-12-20', 'odd'  , nil         , false],   # 0-2
      ['teaching', '2015-12-21', '2015-12-21', 'even' , :wednesday  , true ],   # 3
      ['teaching', '2015-12-22', '2015-12-22', 'odd'  , :tuesday    , true ],   # 3
      ['holiday' , '2015-12-23', '2016-01-03', nil   , nil         , false],   # 3-4
      ['teaching', '2016-01-04', '2016-01-06', 'odd'  , nil         , false],   # 5
      ['exams'   , '2016-01-07', '2016-01-15', nil   , nil         , false]    # 5-6
    ].map do |row|
      Fabricate.build :semester_period,
        type: row[0],
        starts_at: row[1],
        ends_at: row[2],
        first_week_parity: row[3],
        first_day_override: row[4],
        irregular: row[5]
    end
  end

  # This is what the .resolve_weeks method should produce.
  let(:semester_weeks) do
    [# start_date  , periods, teaching_week
      ['2015-11-30', 0      , 1  ],  # 0
      ['2015-12-07', 0      , 2  ],  # 1
      ['2015-12-14', 0      , 3  ],  # 2
      ['2015-12-21', (1..3) , nil],  # 3
      ['2015-12-28', 3      , nil],  # 4
      ['2016-01-04', (4..5) , 4  ],  # 5
      ['2016-01-11', 5      , nil]   # 6
    ].map { |(start_date, periods, teaching_week)|
      periods = Array(periods).map { |idx| semester_periods[idx] }
      described_class.new(semester, periods, Date.parse(start_date), teaching_week)
    }
  end

  subject(:semester_week) { semester_weeks[0] }


  describe '.resolve_weeks' do
    subject(:actual) { described_class.resolve_weeks(semester) }

    it 'returns resolved semester weeks' do
      expect( actual.map(&:start_date) ).to eq semester_weeks.map(&:start_date)
      expect( actual ).to eq semester_weeks
    end

    context 'with from/to' do

      where :start_date, :end_date, :expected_weeks_idx, :desc do
        '2015-12-07' | '2015-12-20' | (1..2) | 'is from Monday to Sunday of next week'
        '2015-12-09' | '2016-01-02' | (1..4) | 'starts/ends in middle of weeks'
        '2015-12-21' | '2015-12-22' | 3      | 'does not cover all periods of the week'
      end

      with_them ->{ "when range #{desc}" } do
        subject(:actual) do
          described_class.resolve_weeks(semester,
            from: Date.parse(start_date),
            to: Date.parse(end_date))
        end

        let(:expected) do
          Array(expected_weeks_idx).map { |idx| semester_weeks[idx] }
        end

        it 'returns weeks in the range' do
          actual_weeks_idx = actual.map { |o| semester_weeks.index(o) }
          expect( actual_weeks_idx ).to eq Array(expected_weeks_idx)
        end

        it 'returns weeks with all periods that intersect them' do
          expect( actual.map(&:periods) ).to eq expected.map(&:periods)
        end

        it 'returns weeks with correct teaching_week number' do
          expect( actual.map(&:teaching_week) ).to eq expected.map(&:teaching_week)
        end
      end
    end
  end

  describe '#periods' do
    subject { semester_week.periods }
    it { should be_frozen }
  end

  describe '#start_date' do
    subject { semester_week.start_date }
    it { should be_frozen }
  end

  describe '#days' do
    subject(:days) { semester_week.days }
    let(:semester_week) { semester_weeks[5] }

    it { should be_frozen }

    it 'returns days with correct period' do
      expected = ([4] * 3 + [5] * 4).map { |idx| semester_periods[idx] }
      expect( days.map(&:period) ).to eq expected
    end

    it 'returns days with correct date' do
      expected = (4..10).map { |d| Date.parse("2016-01-#{d}") }
      expect( days.map(&:date) ).to eq expected.to_a
    end

    it 'returns days with the same teaching_week as this week' do
      expect( days.map(&:teaching_week).uniq ).to eq [4]
    end
  end

  describe '#end_date' do
    let(:semester_week) { semester_weeks[0] }

    it 'returns date of the last day of the week' do
      expect( semester_week.end_date ).to eq Date.parse('2015-12-06')
    end
  end

  describe '#period_types' do
    subject { semester_week.period_types }

    it { should be_frozen }

    context 'week contains multiple regular periods' do
      let(:semester_week) { semester_weeks[5] }

      it 'returns types of all the periods' do
        should eq ['teaching', 'exams']
      end

      context 'of the same type' do
        let(:week_periods) { semester_periods[1..3].each { |p| p.irregular = false } }
        let(:semester_week) { described_class.new(semester, week_periods, Date.parse('2015-12-21')) }

        it 'returns deduplicated types' do
          should eq ['teaching', 'holiday']
        end
      end
    end

    context 'week contains regular and irregular periods' do
      let(:semester_week) { semester_weeks[3] }

      it 'returns only types of regular periods' do
        should eq ['holiday']
      end
    end
  end

  describe '#teaching?' do

    where :week_idx, :expected, :desc do
      5 | true  | 'a regular teaching period'
      3 | false | 'only irregular teaching periods'
      4 | false | 'no teaching period'
    end

    with_them ->{ "week includes #{desc}" } do
      subject { semester_weeks[week_idx].teaching? }
      it { should eq expected }
    end
  end

  describe '#week_parity' do
    subject { semester_week.week_parity }

    where :week_idx, :expected, :desc do
      0 | 'odd'  | 'first week of a teaching period'
      1 | 'even' | 'week after start of a teaching period'
      5 | 'odd'  | 'first week of a second teaching period'
      3 | nil    | 'week with only irregular teaching periods'
      4 | nil    | 'week inside a holiday period'
      6 | nil    | 'week inside an exams period'
    end

    with_them ->{ desc } do
      let(:semester_week) { semester_weeks[week_idx] }

      it 'returns correct parity' do
        should eq expected
      end
    end
  end
end
