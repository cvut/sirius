require 'spec_helper'
require 'interactors/fetch_updated_parallels'
require 'sirius/updated_parallels_finder'

describe FetchUpdatedParallels do

  let(:result) { double(:result).as_null_object }
  let(:finder) { instance_double(Sirius::UpdatedParallelsFinder, find_updated: result) }
  subject(:fetch) { described_class.new }

  before { fetch.setup(finder: finder) }

  describe '#perform' do

    it 'retrieves updated parallels' do
      expect(finder).to receive(:find_updated)
      fetch.perform
    end

    it 'accepts optional range parameters' do
      since = double(:since)
      till = double(:till)
      expect(finder).to receive(:find_updated).with(since, till, faculty: nil, semester: nil)
      fetch.perform(last_updated_since: since, last_updated_till: till)
    end

    it 'stores result in @results' do
      expect(finder).to receive(:find_updated).and_return(result)
      fetch.perform
      expect(fetch.results).to include kosapi_parallels: result
    end

    it 'stores current faculty in @results' do
      expect(finder).to receive(:find_updated).and_return(result)
      fetch.perform(faculty: 18_000)
      expect(fetch.results).to include faculty: 18_000
    end

  end

end
