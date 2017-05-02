require 'spec_helper'
require 'sequel/plugins/enum'

Sequel.extension :migration

describe Sequel::Plugins::Enum do
  Migration = Sequel.migration do
    up do
      extension :pg_enum
      create_enum :test_enum, %w(a b c)
      create_table(:enum_test_models) do
        String :str_col
        test_enum :enum_col
      end
    end

    down do
      extension :pg_enum
      drop_table :enum_test_models
      drop_enum :test_enum
    end
  end

  before(:all) do
    Migration.apply(DB, :up)
  end

  after(:all) do
    Migration.apply(DB, :down)
  end

  let(:model) do
    class EnumTestModel < Sequel::Model
      plugin :enum
      enum :enum_col
    end
    EnumTestModel
  end

  describe '.enum' do
    it 'enables an enum column' do
      expect { model.enum :enum_col }.to_not raise_error
    end
    context 'with non-enum column' do
      it 'raises an ArgumentError' do
        expect { model.enum :str_col }.to raise_error(ArgumentError)
      end
    end
  end

  describe '.enums' do
    it 'contains allowed values for enum' do
      expected = {enum_col: Set.new(%w'a b c')}
      expect(model.enums).to eq(expected)
    end
  end

  describe 'instance methods' do
    subject(:instance) { model.new }
    describe 'enum getter' do
      it 'returns value as symbol' do
        instance.enum_col = 'a'
        expect(instance.enum_col).to be_a(Symbol)
      end
    end

    describe 'enum setter' do
      context 'with invalid enum value' do
        it 'raises an ArgumentError' do
          expect { instance.enum_col = 'invalid' }.to raise_error(ArgumentError)
        end
      end

      context 'with valid enum value' do
        it 'accepts string' do
          instance.enum_col = 'b'
          expect(instance.enum_col).to eq :b
        end

        it 'accepts symbol' do
          instance.enum_col = :c
          expect(instance.enum_col).to eq :c
        end
      end
    end
  end
end
