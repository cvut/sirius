require 'spec_helper'
require 'interpipe/organizer'

describe Interpipe::Organizer do

  subject(:organizer) { described_class }
  let(:interactor1) { double(:first).as_null_object }
  let(:interactor2) { double(:second).as_null_object }

  describe '.interactors=' do
    it 'sets interactors' do
      expect{
        organizer.interactors = [interactor1, interactor2]
      }.to change {
        organizer.interactors
      }.from([]).to([interactor1, interactor2])
    end
  end

end
