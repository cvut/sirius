require 'rspec-parameterized'
require 'spec_helper'

require 'sirius/teaching_time'

describe Sirius::TeachingTime do
  using RSpec::Parameterized::TableSyntax

  subject(:teaching_time) do
    described_class.new(teaching_period: Period.parse('14:30', '16:00'),
                        parity: parity, day: input_day, start_date: start_date, end_date: end_date)
  end
  let(:parity) { 'odd' }
  let(:input_day) { :tuesday }
  let(:start_date) { nil }
  let(:end_date) { nil }

  describe '#week_frequency' do
    where :parity, :week_frequency do
          'odd'  | 2
          'even' | 2
          'both' | 1
          nil    | 1
    end
    with_them ->{ "with #{parity} parity" } do
      it 'returns correct frequency' do
        expect(teaching_time.week_frequency).to eq week_frequency
      end
    end
  end

  describe '#duration' do
    it 'returns difference between start and end' do
      expect(subject.duration).to eq 90.minutes
    end
  end

  describe '#to_recurrence_rule' do
    let(:ends_at) { DateTime.parse('2020-03-11') }

    it 'returns weekly recurrence rule' do
      expect(subject.to_recurrence_rule(0, ends_at)).to be_an_instance_of IceCube::WeeklyRule
    end

    it 'returns terminating rule' do
      expect(subject.to_recurrence_rule(0, ends_at)).to be_terminating
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
        rule = subject.to_recurrence_rule(offset, ends_at)
        expect(rule.validations[:day].first.day).to eq result_day
      end
    end

    context 'when start/end dates were not provided' do
      it 'returns recurrence rule ending at the given ends_at date' do
        expect(
          subject.to_recurrence_rule(0, ends_at).until_time.strftime("%F")
        ).to eq ends_at.strftime("%F")
      end
    end

    context 'when start/end dates were provided' do
      let(:period) { nil }
      let(:start_date) { Date.parse('2020-02-20') }
      let(:end_date) { Date.parse('2020-02-26') }

      it 'returns recurrence rule ending at the end_date' do
        expect(
          subject.to_recurrence_rule(0, ends_at).until_time.strftime("%F")
        ).to eq end_date.strftime("%F")
      end
    end
  end
end
