require 'spec_helper'

describe Sirius::ScheduleManager do

  subject(:manager) { Sirius::ScheduleManager.new }

  it 'plans all parallels stored in DB' do
    manager.plan_stored_parallels

  end



end