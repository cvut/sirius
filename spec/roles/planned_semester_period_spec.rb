require 'spec_helper'
require 'period'
require 'roles/planned_semester_period'

describe PlannedSemesterPeriod do

  subject(:period) { create_period('17.2.2014', '16.5.2014') }
  let(:teaching_day) { :tuesday }
  let(:teaching_time) { Sirius::TeachingTime.new(teaching_period: Period.new(Time.parse('14:30'), Time.parse('16:00')), parity: :both, day: teaching_day) }

  it 'plans weekly event into semester calendar correctly' do
    events = period.plan(teaching_time)
    expect(events.first).to eq(Period.parse('18.2.2014 14:30', '18.2.2014 16:00'))
    expect(events.last).to eq(Period.parse('13.5.2014 14:30', '13.5.2014 16:00'))
    expect(events.length).to be 13
  end

  it 'plans odd week event into semester calendar correctly' do
    teaching_time.parity = :odd
    events = period.plan(teaching_time)
    expect(events.first).to eq(Period.parse('25.2.2014 14:30', '25.2.2014 16:00'))
    expect(events.last).to eq(Period.parse('6.5.2014 14:30', '6.5.2014 16:00'))
    expect(events.length).to be 6
  end

  it 'plans even week event into semester calendar correctly' do
    teaching_time.parity = :even
    events = period.plan(teaching_time)
    expect(events.first).to eq(Period.parse('18.2.2014 14:30', '18.2.2014 16:00'))
    expect(events.last).to eq(Period.parse('13.5.2014 14:30', '13.5.2014 16:00'))
    expect(events.length).to be 7
  end

  context 'with first_day_override' do
    subject(:period) { create_period('22.12.2015', '22.12.2015', first_day_override: 3) }

    it 'does not plan events from other weekdays' do
      events = period.plan(teaching_time)
      expect(events).to be_empty
    end

    context 'for matching teaching time weekday' do
      let(:teaching_day) { :wednesday }

      it 'plans events from overriding day' do
        events = period.plan(teaching_time)
        expect(events).to contain_exactly(Period.parse('22.12.2015 14:30', '22.12.2015 16:00'))
      end

      it 'does not plan teaching times with opposite parity' do
        teaching_time.parity = :odd
        events = period.plan(teaching_time)
        expect(events).to be_empty
      end
    end
  end

  it 'returns two Time instances in Period' do
    event = period.plan(teaching_time).first
    expect(event.starts_at).to be_an_instance_of(Time)
    expect(event.ends_at).to be_an_instance_of(Time)
  end

  def create_period(starts_at, ends_at, first_day_override: nil)
    period = Fabricate(:teaching_semester_period,
                      starts_at: Time.parse(starts_at),
                      ends_at: Time.parse(ends_at),
                      first_week_parity: :even,
                      first_day_override: first_day_override)
    described_class.new(period)
  end
end
