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

    subject(:sync) { described_class[Person]}

    it 'inserts new entity' do
      person = Fabricate.build(:person)
      expect { sync.perform({people: [person]}) }.to change(person, :new?).from(true).to(false)
    end

    context 'with existing record' do

      let(:existing_person) { Fabricate(:person, full_name: 'Dude') }
      let(:person) { Fabricate.build(:person, id: existing_person.id, full_name: 'Mr. Dude') }

      it 'updates existing entity' do
        expect do
          sync.perform({people: [person]})
          existing_person.refresh
        end.to change(existing_person, :full_name).from('Dude').to('Mr. Dude')
      end

      it 'updates updated_at timestamp' do
        expect do
          sync.perform({people: [person]})
          existing_person.refresh
        end.to change(existing_person, :updated_at)
      end

      it 'keeps created_at timestamp' do
        expect do
          sync.perform({people: [person]})
          existing_person.refresh
        end.not_to change(existing_person, :created_at)
      end

    end

    context 'with invalid input' do

      it 'raises RuntimeError' do
        expect { sync.perform({}) }.to raise_error(RuntimeError)
      end

    end

  end

end
