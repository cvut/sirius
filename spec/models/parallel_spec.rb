require 'spec_helper'
require 'models/parallel'
require 'models/person'
require 'sirius/time_converter'

describe Parallel do

  subject(:parallel) { Parallel.new(code: 101) }

  describe '#to_s' do
    it 'is aliased to a code' do
      expect(parallel.to_s).to eql '101'
    end
  end
end
