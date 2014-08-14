require 'spec_helper'
require 'interactors/sync'

describe Sync do

  describe '.[]' do

    it 'returns anonymous subclass of Sync' do
      cls = described_class[String]
      expect(cls).to be < described_class
    end

    it 'sets model_class attribute' do
      cls = described_class[String]
      expect(cls.model_class).to eq String
    end

    it 'can set key_name attribute' do
      cls = described_class[String, :foo]
      expect(cls.key_name).to eq :foo
    end

    it 'plularizes model_class as default key_name' do
      cls = described_class[String]
      expect(cls.key_name).to eq :strings
    end
  end

  describe '#perform' do

  end

end
