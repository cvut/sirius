require 'spec_helper'
require 'sirius/semester_calendar'
require 'period'

describe Sirius::SemesterCalendar do

  let(:teaching_time) { Sirius::TeachingTime.new(teaching_period: Period.new(Time.parse('14:30'), Time.parse('16:00')), parity: :both, day: :tuesday) }
  let(:schedule_params) { { teaching_period: Period.new(Time.parse('17.2.2014'), Time.parse('16.5.2014')), first_week_parity: :even } }
  subject(:calendar) { Sirius::SemesterCalendar.new(schedule_params) }

  it 'plans weekly event into semester calendar correctly' do
    events = calendar.plan(teaching_time)
    expect(events.first).to eq(Period.parse('18.2.2014 14:30', '18.2.2014 16:00'))
    expect(events.last).to eq(Period.parse('13.5.2014 14:30', '13.5.2014 16:00'))
    expect(events.length).to be 13
  end

  it 'plans odd week event into semester calendar correctly' do
    teaching_time.parity = :odd
    events = calendar.plan(teaching_time)
    expect(events.first).to eq(Period.parse('25.2.2014 14:30', '25.2.2014 16:00'))
    expect(events.last).to eq(Period.parse('6.5.2014 14:30', '6.5.2014 16:00'))
    expect(events.length).to be 6
  end

  it 'plans even week event into semester calendar correctly' do
    teaching_time.parity = :even
    events = calendar.plan(teaching_time)
    expect(events.first).to eq(Period.parse('18.2.2014 14:30', '18.2.2014 16:00'))
    expect(events.last).to eq(Period.parse('13.5.2014 14:30', '13.5.2014 16:00'))
    expect(events.length).to be 7
  end

  it 'returns two Time instances in Period' do
    event = calendar.plan(teaching_time).first
    expect(event.starts_at).to be_an_instance_of(Time)
    expect(event.ends_at).to be_an_instance_of(Time)
  end

end
