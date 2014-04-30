require 'spec_helper'

describe Sirius::ScheduleManager do

  subject(:manager) { Sirius::ScheduleManager.new }

  it 'plans all parallels stored in DB' do
    Fabricate(:timetable_slot)
    manager.plan_stored_parallels
    # expect(Events.all).to
  end



end