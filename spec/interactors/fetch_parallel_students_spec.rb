require 'spec_helper'
require 'interactors/fetch_parallel_students'

describe FetchParallelStudents do

  describe '#perform' do

    subject { described_class }

    let(:student) { double(:student) }
    let(:parallel) { double(:parallel, id: 42) }
    let(:client) { double(:client).as_null_object }

    it 'returns students in results' do
      fetch = FetchParallelStudents.new
      allow(fetch).to receive(:fetch_students).and_return([student])
      fetch.perform(parallels: [parallel])
      expect(fetch.results[:students]).to eq({parallel => [student]})
    end

    it 'fetches students from KOSapi' do
      expect(client).to receive(:students)
      fetch = FetchParallelStudents.new
      fetch.setup(client: client)
      fetch.perform(parallels: [parallel])
    end


  end

end
