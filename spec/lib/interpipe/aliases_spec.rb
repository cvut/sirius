require 'spec_helper'
require 'interpipe/aliases'

describe Interpipe::Aliases do

  subject(:klass) { Class.new.include Interpipe::Aliases }

  describe '.pipe' do

    it 'calls Pipe[]' do
      expect(Interpipe::Pipe).to receive(:[]).with(:foo, :bar, :bah)
      klass.pipe[ :foo, :bar, :bah ]
    end

  end

  describe '.split' do

    it 'calls Splitter[]' do
      expect(Interpipe::Splitter).to receive(:[]).with(:foo, :bar, :bah)
      klass.split[ :foo, :bar, :bah ]
    end

  end

end
