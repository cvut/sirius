require 'spec_helper'
require 'sirius/kosapi_client_registry'
require 'sirius/schedule_manager'

describe Sirius::ScheduleManager, :vcr do

  before do
    allow(Sirius::KOSapiClientRegistry.instance).to receive(:client_for_faculty)
      .and_return(create_kosapi_client)
  end

  let!(:semester) { Fabricate(:faculty_semester) }
  subject(:manager) { Sirius::ScheduleManager.new }

  it 'fetches parallels from KOSapi' do
    expect {
      manager.import_parallels(fetch_all: false, page_size: 10)
    }.to change(Parallel, :count).from(0)
  end


end
