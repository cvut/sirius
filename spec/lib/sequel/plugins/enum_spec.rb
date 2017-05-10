require 'spec_helper'
require 'sequel/plugins/enum'

Sequel.extension :migration

describe Sequel::Plugins::Enum do
  Migration = Sequel.migration do
    up do
      extension :pg_enum
      create_enum :test_enum, %w(a b c)
      create_enum :test_enum2, %w(d e f)
      create_table(:enum_test_models) do
        String :str_col
        String :kind
        test_enum :enum_col
        test_enum2 :enum_col2
      end
    end

    down do
      extension :pg_enum
      drop_table :enum_test_models
      drop_enum :test_enum
      drop_enum :test_enum2
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
    end
    EnumTestModel
  end

  let(:enums_schema) do
    {
      enum_col: Set.new(%w'a b c'),
      enum_col2: Set.new(%w'd e f'),
    }
  end

  describe '.plugin :enum' do
    it 'enables enum columns' do
      expect { model.plugin :enum }.to_not raise_error
    end
  end

  describe '.enums' do
    before do
      model.plugin :enum
    end
    it 'contains allowed values for enum' do
      expect(model.enums).to eq(enums_schema)
    end
  end

  describe 'instance methods' do
    subject(:instance) do
      model.plugin :enum
      model.new
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
          expect(instance.enum_col).to eq 'b'
        end

        it 'accepts symbol' do
          instance.enum_col = :c
          expect(instance.enum_col).to eq 'c'
        end
      end
    end
  end

  context 'in subclass' do
    let!(:model) do
      class EnumTestModel < Sequel::Model
        plugin :enum
        plugin :single_table_inheritance, :kind
      end
      EnumTestModel
    end

    let(:submodel) do
      class SubEnumTestModel < EnumTestModel
      end
      SubEnumTestModel
    end

    let!(:instance) { submodel.create(enum_col: 'b') }

    describe '.enums' do
      before do
        model.plugin :enum
      end
      it 'contains allowed values for enum' do
        expect(model.enums).to eq(enums_schema)
        expect(submodel.enums).to eq(enums_schema)
      end
      it 'is a different object' do
        expect(model.enums).to_not equal(submodel.enums)
      end
    end


  end
end
