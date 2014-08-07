require 'spec_helper'
require 'interpipe/pipe'

describe Interpipe::Pipe do
  let(:pipe) { described_class }
  let(:interactor1) { double(:first).as_null_object }
  let(:interactor2) { double(:second).as_null_object }

  describe '.[]' do

    it 'creates new anonymous pipe class' do
      anonymous_pipe = Interpipe::Pipe[]
      expect(anonymous_pipe).to be < Interpipe::Pipe
    end

    it 'sets interactors of newly created class' do
      anonymous_pipe = Interpipe::Pipe[interactor1, interactor2]
      expect(anonymous_pipe.interactors).to eq [interactor1, interactor2]
    end

  end

  describe '#perform' do
    before do
      allow(pipe).to receive(:interactors) { [interactor1, interactor2] }
    end

    it 'passes arguments to the first interactor' do
      expect(interactor1).to receive(:perform).once.with(key: 'value') { interactor1 }
      pipe.perform(key: 'value')
    end

    it 'passes results of the previous interactor' do
      allow(interactor1).to receive(:results) { {second: 'another value'} }
      expect(interactor2).to receive(:perform).once.with(second: 'another value')
      pipe.perform
    end
  end

  describe '#results' do
    subject(:results) { pipe.perform.results }

    before do
      allow(pipe).to receive(:interactors) { [interactor1] }
    end
    it 'sets a results of the last interactor' do
      rs = {lorem: 'ipsum', dolor: 'sit'}
      allow(interactor1).to receive(:results) { rs }
      expect(results).to eql(rs)
    end
  end

end
