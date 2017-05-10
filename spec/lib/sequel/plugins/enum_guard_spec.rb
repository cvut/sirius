require 'spec_helper'
require 'sequel/plugins/enum_guard'

Sequel.extension :migration

describe Sequel::Plugins::EnumGuard do
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

  let(:enums_schema) do
    {
      enum_col: Set.new(%w'a b c'),
      enum_col2: Set.new(%w'd e f'),
    }
  end

  before do
    Sequel::Model.plugin :enum_guard
  end

  context 'within global Sequel::Model' do
    subject(:model) do
      Sequel::Model
    end

    it { should_not respond_to(:enums) }
  end

  context 'within model with enums' do
    subject(:model) do
      class EnumTestModel < Sequel::Model
      end
      EnumTestModel
    end

    describe '.enums' do
      subject(:enums) { model.enums }

      it 'contains allowed values for enum' do
        expect(enums).to eq(enums_schema)
      end

      it { should be_frozen }
    end

    describe 'instance methods' do
      subject(:instance) do
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
  end

  context 'in subclass' do
    let!(:model) do
      class EnumTestModel < Sequel::Model
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
