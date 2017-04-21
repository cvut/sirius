require 'spec_helper'
require 'interactors/sync'
require 'models/person'
require 'models/room'

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
      cls = described_class[String, key_name: :foo]
      expect(cls.key_name).to eq :foo
    end

    it 'can set key_name attribute' do
      cls = described_class[String, matching_attributes: [:foo]]
      expect(cls.matching_attributes).to contain_exactly :foo
    end

    it 'plularizes model_class as default key_name' do
      cls = described_class[String]
      expect(cls.key_name).to eq :strings
    end
  end

  describe '#perform' do

    subject(:sync) { described_class[Person]}
    let(:person) { Fabricate.build(:person) }

    it 'inserts new entity' do
      expect { sync.perform({people: [person]}) }.to change(person, :new?).from(true).to(false)
    end

    %i(created_at updated_at).each do |attr|
      it "sets #{attr} on insert" do
        expect {
          sync.perform({people: [person]})
          person.refresh
        }.to change(person, attr).from(nil)
      end
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

      it 'does not update update_at when nothing is changed' do
        expect do
          sync.perform({people: [existing_person]})
          existing_person.refresh
        end.not_to change(existing_person, :updated_at)
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

    context 'with custom key_name' do

      subject(:sync) { described_class[Person, key_name: :foo] }

      it 'accepts input from it' do
        expect { sync.perform({foo: []}) }.not_to raise_error
      end

    end

    context 'with custom matching_attributes' do

      subject(:sync) { described_class[Person, matching_attributes: [:access_token], skip_updating: [:id]] }
      let!(:saved_person) do
        Fabricate(:person, full_name: 'Pete', access_token: 'a41a01cc-2698-437b-9bfb-387f1863937c')
      end
      let(:new_person) do
        Fabricate.build(:person,
          full_name: 'Peter',
          access_token: 'a41a01cc-2698-437b-9bfb-387f1863937c'
        )
      end

      it 'updates model according to it' do
        expect do
          sync.perform({people: [new_person]})
          saved_person.refresh
        end.to change(saved_person, :full_name).from('Pete').to('Peter')
      end

    end

    it 'puts saved entities into results' do
      results = sync.perform({people: [person]}).results
      expect(results).to include people: [person]
    end

    it 'passes other data along' do
      results = sync.perform({people: [], foo: :bar}).results
      expect(results).to include foo: :bar
    end

    context 'with skip_updating' do

      let!(:person) { Fabricate(:person, full_name: 'Pete') }
      subject(:sync) { described_class[Person, skip_updating: [:full_name]] }

      it 'skips updating specified attributes' do
        person.full_name = 'Joe'
        expect do
          sync.perform({people: [person]})
          person.refresh
        end.to change(person, :full_name).from('Joe').to('Pete')
      end

    end

  end

  describe '#results' do
    let(:sync) { described_class[Room]}

    it 'returns models in case of update' do
      Fabricate(:room, id: 'A-1324')
      room = Room.new(kos_code: 'A-1324')
      results = sync.perform({rooms: [room], other_stuff: []}).results[:rooms]
      expect(results).to include room
      expect(results.first.kos_code).to eq 'A-1324'
    end

  end
end
