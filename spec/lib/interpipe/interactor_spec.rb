require 'spec_helper'
require 'interpipe/interactor'

describe Interpipe::Interactor do
  class TestInteractor
    include Interpipe::Interactor
  end

  let(:interactor) { TestInteractor }
  def performance # do not cache return value
    interactor.perform(key: 'value', lorem: 'ipsum')
  end

  describe '.perform' do
    it 'returns an interactor instance' do
      expect(performance).to be_a TestInteractor
    end
    it 'expands the arguments' do
      expect_any_instance_of(interactor).to receive(:perform).with(key: 'value', lorem: 'ipsum')
      performance
    end
  end

  describe '#setup' do
    it 'calls setup on instance initizalization' do
      expect_any_instance_of(interactor).to receive(:setup)
      interactor.perform(key: '')
    end
  end

  describe '#results' do
    it 'is a hash' do
      expect(performance.results).to eql({})
    end
  end
end
