require 'spec_helper'
require 'sirius/schedule_manager'

describe Sirius::ScheduleManager do

  subject(:manager) { Sirius::ScheduleManager.new }

  it 'fetches parallels from KOSapi' do
    manager.fetch_and_store_parallels
    expect(Parallel.count).to be > 0
  end


end
