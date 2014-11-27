require 'spec_helper'
require 'interactors/load_parallels'

describe LoadParallels do

  describe '#perform' do

    subject { described_class }
    let(:faculty_semester) { double(code: 'B141', faculty: 18_000) }

    it 'loads paralels from database' do
      expect(Parallel).to receive(:where).and_return(Parallel)
      expect(Parallel).to receive(:all)
      subject.perform(faculty_semester: faculty_semester)
    end

    it 'sets result variable' do
      allow(Parallel).to receive(:where).and_return(Parallel)
      allow(Parallel).to receive(:all).and_return(:foo)
      expect(subject.perform(faculty_semester: faculty_semester).results[:parallels]).to eq :foo
    end

  end

end
