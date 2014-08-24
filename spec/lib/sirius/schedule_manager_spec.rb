require 'spec_helper'
require 'sirius/schedule_manager'

describe Sirius::ScheduleManager do

  subject(:manager) { Sirius::ScheduleManager.new }

  it 'plans all slots stored in DB' do
    Fabricate(:timetable_slot)
    expect {
      manager.plan_stored_parallels
    }.to change(Event, :count).from(0)
  end

  it 'synchronizes already generated events' do
    Fabricate(:timetable_slot)
    manager.plan_stored_parallels
    expect {
      manager.plan_stored_parallels
    }.not_to change(Event, :count)
  end

end
