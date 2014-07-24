require 'spec_helper'
require 'sirius/schedule_manager'

describe Sirius::ScheduleManager, :vcr do

  subject(:manager) { Sirius::ScheduleManager.new(client: create_kosapi_client) }

  it 'fetches parallels from KOSapi' do
    manager.fetch_and_store_parallels
    expect(Parallel.count).to be > 0
  end


end
