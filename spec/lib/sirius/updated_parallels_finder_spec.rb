require 'spec_helper'
require 'sirius/updated_parallels_finder'

describe Sirius::UpdatedParallelsFinder, :vcr do

  let(:since) { Time.parse('1.7.2014') }
  let(:till) { Time.parse('10.7.2014') }
  subject(:finder) { Sirius::UpdatedParallelsFinder.new(client: create_kosapi_client) }

  it 'finds parallels updated since' do
    parallels = finder.find_updated(since, page_size: 10)
    parallels.auto_paginate = false
    expect(parallels.any? { |par| par.updated > since }).to be_truthy
  end

  it 'finds parallels updated between' do
    parallels = finder.find_updated(since, till, page_size: 10)
    parallels.auto_paginate = false
    expect(parallels.any? { |par| par.updated > since }).to be_truthy
  end


end
