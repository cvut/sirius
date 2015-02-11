require 'spec_helper'

require 'interactors/extract_items'

describe ExtractItems do

  context 'instance methods' do
    subject { described_class[:bars, from: :foo, attr: :bar].new }
    let(:room) { double(:room, link_id: '42') }
    let(:options) { {foo: [double(bar: room), double(bar: room), double(bar: nil)], baz: 42 } }

    describe '#perform' do
      it 'deduplicates records' do
        subject.perform(options)
        expect(subject.results[:bars]).to contain_exactly(room)
      end
    end

    describe '#results' do
      it 'passes any other arguments through' do
        subject.perform(options)
        expect(subject.results[:baz]).to eq 42
      end
    end
  end

  context 'class methods' do
    subject { described_class[:bars, from: :foo, attr: :bar] }

    it 'creates new subclass' do
      expect(subject).to be < described_class
    end
  end
end
