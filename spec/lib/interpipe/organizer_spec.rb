require 'spec_helper'
require 'interpipe/organizer'

describe Interpipe::Organizer do
  let(:organizer) { Class.new(Interpipe::Organizer) }
  let(:interactor) { Class.new.send(:include, Interpipe::Interactor) }
  let(:interactor1) { double(:first).as_null_object }
  let(:interactor2) { double(:second).as_null_object }

  describe '.interactors=' do
    it 'sets organized interactors' do
      expect{
        organizer.interactors = [interactor1, interactor2]
      }.to change {
        organizer.interactors
      }.from([]).to([interactor1, interactor2])
    end
  end

  describe '#perform' do
    it 'raises an error' do
      expect { organizer.perform }.to raise_error(NotImplementedError)
    end
  end

end
