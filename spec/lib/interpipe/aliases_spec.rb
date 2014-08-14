require 'spec_helper'
require 'interpipe/pipe'
require 'interpipe/splitter'
require 'interpipe/aliases'

describe Interpipe::Aliases do

  subject { Class.new().extend Interpipe::Aliases }

  describe '.pipe' do

    it 'calls Pipe[]' do
      expect(Interpipe::Pipe).to receive(:[]).with(:foo, :bar, :bah)
      subject.pipe[ :foo, :bar, :bah ]
    end

  end

  describe '.split' do

    it 'calls Splitter[]' do
      expect(Interpipe::Splitter).to receive(:[]).with(:foo, :bar, :bah)
      subject.split[ :foo, :bar, :bah ]
    end

  end

end
