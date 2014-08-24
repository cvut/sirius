require 'spec_helper'
require 'sirius/schedule_manager'

describe Sirius::ScheduleManager, :vcr do

  subject(:manager) { Sirius::ScheduleManager.new(client: create_kosapi_client) }

  it 'fetches parallels from KOSapi' do
    expect {
      manager.fetch_and_store_parallels(fetch_all: false)
    }.to change(Parallel, :count).from(0)
  end


end
