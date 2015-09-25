require 'spec_helper'
require 'sirius/schedule_manager'

describe Sirius::ScheduleManager, :vcr do

  before { allow(KOSapiClient).to receive(:client).and_return(create_kosapi_client) }

  let!(:semester) { Fabricate(:faculty_semester) }
  subject(:manager) { Sirius::ScheduleManager.new }

  it 'fetches parallels from KOSapi' do
    expect {
      manager.import_parallels(fetch_all: false, page_size: 10)
    }.to change(Parallel, :count).from(0)
  end


end
