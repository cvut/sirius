require 'spec_helper'
require 'interpipe/interactor'

describe Interpipe::Interactor do
  class TestInteractor
    include Interpipe::Interactor

    def perform(key:, **options)
      options
    end
  end

  let(:interactor) { TestInteractor }

  describe '.perform' do
    it 'expands the arguments' do
      expect_any_instance_of(interactor).to receive(:perform).with(key: 'value')
      interactor.perform(key: 'value')
    end

    it 'passes extra arguments' do
      expect(interactor.perform(key: 'value', lorem: 'ipsum')).to eql({lorem: 'ipsum'})
    end
  end

end
