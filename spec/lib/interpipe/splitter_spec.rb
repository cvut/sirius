require 'spec_helper'
require 'interpipe/splitter'

describe Interpipe::Splitter do
  let(:splitter) { described_class }
  let(:interactor1) { double(:first).as_null_object }
  let(:interactor2) { double(:second).as_null_object }

  describe '#perform' do
    before do
      allow(splitter).to receive(:interactors) { [interactor1, interactor2] }
    end

    it 'passes arguments to the first interactor' do
      expect(interactor1).to receive(:perform).once.with(key: 'value') { interactor1 }
      splitter.perform(key: 'value')
    end

    it 'passes same arguments to the second interactor' do
      allow(interactor1).to receive(:results) { {second: 'another value'} }
      expect(interactor2).to receive(:perform).once.with(key: 'value')
      splitter.perform(key: 'value')
    end
  end

  describe '#results' do
    subject(:results) { splitter.perform.results }

    before do
      allow(splitter).to receive(:interactors) { [interactor1] }
    end
    it 'sets results of all interactors' do
      rs = {lorem: 'ipsum', dolor: 'sit'}
      allow(interactor1).to receive(:results) { rs }
      expect(results).to contain_exactly rs
    end
  end

end
