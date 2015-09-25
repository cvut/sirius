require 'spec_helper'
require 'sirius/updated_parallels_finder'

describe Sirius::UpdatedParallelsFinder, :vcr do

  let(:since) { Time.parse('1.7.2014') }
  let(:till) { Time.parse('10.7.2014') }
  subject(:finder) { Sirius::UpdatedParallelsFinder.new(client: create_kosapi_client) }

  it 'finds parallels' do
    parallels = finder.find_updated(page_size: 10, faculty: 18000, semester: 'B151')
    parallels.auto_paginate = false
    expect(parallels.count).to eq 10
  end

end
