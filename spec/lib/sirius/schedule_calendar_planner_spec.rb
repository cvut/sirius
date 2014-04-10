require 'spec_helper'

describe Sirius::ScheduleCalendarPlanner do

  let(:teaching_time) { Sirius::TeachingTime.new(teaching_period: Sirius::Period.new(Time.parse('14:30'), Time.parse('16:00')), parity: :both, day: :tuesday) }
  let(:schedule_params) { { teaching_period: Sirius::Period.new(Time.parse('17.2.2014'), Time.parse('16.5.2014')), first_week_parity: :even } }
  subject(:planner) { Sirius::ScheduleCalendarPlanner.new(schedule_params) }



  it 'plans weekly event into semester calendar correctly' do
    events = planner.plan(teaching_time)
    expect(events.first).to eq({starts_at: Time.parse('18.2.2014 14:30'), ends_at: Time.parse('18.2.2014 16:00')})
    expect(events.last).to eq({starts_at: Time.parse('13.5.2014 14:30'), ends_at: Time.parse('13.5.2014 16:00')})
    expect(events.length).to be 13
  end

  it 'plans odd week event into semester calendar correctly' do
    teaching_time.parity = :odd
    events = planner.plan(teaching_time)
    expect(events.first).to eq({starts_at: Time.parse('25.2.2014 14:30'), ends_at: Time.parse('25.2.2014 16:00')})
    expect(events.last).to eq({starts_at: Time.parse('6.5.2014 14:30'), ends_at: Time.parse('6.5.2014 16:00')})
    expect(events.length).to be 6
  end

  it 'plans even week event into semester calendar correctly' do
    teaching_time.parity = :even
    events = planner.plan(teaching_time)
    expect(events.first).to eq({starts_at: Time.parse('18.2.2014 14:30'), ends_at: Time.parse('18.2.2014 16:00')})
    expect(events.last).to eq({starts_at: Time.parse('13.5.2014 14:30'), ends_at: Time.parse('13.5.2014 16:00')})
    expect(events.length).to be 7
  end

end