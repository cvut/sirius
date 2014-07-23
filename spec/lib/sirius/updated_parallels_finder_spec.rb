require 'spec_helper'
require 'sirius/updated_parallels_finder'

describe Sirius::UpdatedParallelsFinder do

  let(:since) { Time.parse('1.7.2014') }
  subject(:finder) { Sirius::UpdatedParallelsFinder.new(since: since) }

  it 'finds parallels updated since' do
    parallels = finder.find_updated
    expect(parallels.first.updated).to be > since
  end
end
