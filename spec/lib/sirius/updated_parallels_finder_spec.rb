require 'spec_helper'
require 'sirius/updated_parallels_finder'

describe Sirius::UpdatedParallelsFinder, :vcr do

  let(:since) { Time.parse('1.7.2014') }
  subject(:finder) { Sirius::UpdatedParallelsFinder.new(since: since) }

  it 'finds parallels updated since' do
    parallels = finder.find_updated
    expect(parallels.any? { |par| par.updated > since }).to be_truthy
  end
end
