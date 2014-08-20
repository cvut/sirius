require 'spec_helper'
require 'interactors/load_parallels'

describe LoadParallels do

  describe '#perform' do

    subject { described_class }

    it 'loads paralels from database' do
      expect(Parallel).to receive(:all)
      subject.perform
    end

    it 'sets result variable' do
      allow(Parallel).to receive(:all).and_return(:foo)
      expect(subject.perform.results[:parallels]).to eq :foo
    end

  end

end
