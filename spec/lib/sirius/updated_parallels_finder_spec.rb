require 'spec_helper'
require 'sirius/updated_parallels_finder'

describe Sirius::UpdatedParallelsFinder, :vcr do

  let(:since) { Time.parse('1.7.2014') }
  subject(:finder) { Sirius::UpdatedParallelsFinder.new(client: create_kosapi_client) }

  it 'finds parallels updated since' do
    parallels = finder.find_updated(since)
    expect(parallels.any? { |par| par.updated > since }).to be_truthy
  end
end
