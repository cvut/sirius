require 'rspec-parameterized'
require 'spec_helper'

require 'sirius/teaching_time'

describe Sirius::TeachingTime do
  using RSpec::Parameterized::TableSyntax

  subject(:teaching_time_with_parity) do
    described_class.new(teaching_period: Period.parse('14:30', '16:00'),
                        parity: parity, day: input_day)
  end
  subject(:teaching_time_with_dates) do
    described_class.new(teaching_period: Period.parse('14:30', '16:00'),
                        parity: nil, day: input_day, start_date: Date.parse('2020-02-20'), end_date: Date.parse('2020-02-26'))
  end
  let(:parity) { 'odd' }
  let(:input_day) { :tuesday }

  describe '#week_frequency' do
    where :parity, :week_frequency do
          'odd'  | 2
          'even' | 2
          'both' | 1
          ''     | 1
          nil    | 1
    end
    with_them ->{ "with #{parity} parity" } do
      it 'returns correct frequency' do
        expect(teaching_time_with_parity.week_frequency).to eq week_frequency
      end
    end

    it 'returns correct frequency with dates specified' do
      expect(teaching_time_with_dates.week_frequency).to eq 1
    end
  end

  describe '#duration' do
    it 'returns difference between start and end' do
      expect(teaching_time_with_parity.duration).to eq 90.minutes
      expect(teaching_time_with_dates.duration).to eq 90.minutes
    end
  end

  describe '#to_recurrence_rule' do
    let(:ends_at) { DateTime.parse('2020-03-11') }

    it 'returns weekly recurrence rule' do
      expect(teaching_time_with_parity.to_recurrence_rule(0, ends_at)).to be_an_instance_of IceCube::WeeklyRule
      expect(teaching_time_with_dates.to_recurrence_rule(0, ends_at)).to be_an_instance_of IceCube::WeeklyRule
    end

    it 'correct recurrence rule until time' do
      expect(teaching_time_with_parity.to_recurrence_rule(0, ends_at).until_time.strftime("%F")).to eq ends_at.strftime("%F")
      expect(teaching_time_with_dates.to_recurrence_rule(0, ends_at).until_time.strftime("%F")).to eq teaching_time_with_dates.end_date.strftime("%F")
    end

    it 'returns terminating rule' do
      expect(teaching_time_with_parity.to_recurrence_rule(0, ends_at)).to be_terminating
      expect(teaching_time_with_dates.to_recurrence_rule(0, ends_at)).to be_terminating
    end

    where :input_day, :offset, :output_day do
          :sunday   |   0    | :sunday
          :monday   |  -1    | :sunday
          :sunday   |  +1    | :monday
          :wednesday|  +7    | :wednesday
          :friday   |  +4    | :tuesday
    end
    with_them ->{ "with input_day #{input_day} and offset #{offset}" } do

      # IceCube indexes days of week from 0 to 6, beginning with Sunday.
      let(:result_day) { (Date::DAYS_INTO_WEEK[output_day] + 1) % 7 }

      it 'sets correct recurrence day' do
        expect(teaching_time_with_parity.to_recurrence_rule(offset, ends_at).validations[:day].first.day).to eq result_day
        expect(teaching_time_with_dates.to_recurrence_rule(offset, ends_at).validations[:day].first.day).to eq result_day
      end
    end
  end

  describe "#only_some_weeks?" do

    it 'returns true if dates are specified and parity is empty' do
      expect(teaching_time_with_dates.only_some_weeks?).to eq true
      expect(teaching_time_with_parity.only_some_weeks?).to eq false
    end

  end

end
