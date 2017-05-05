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

  describe '.plugin :enum' do
    it 'enables enum columns' do
      expect { model.plugin :enum, :enum_col, :enum_col2 }.to_not raise_error
    end
    context 'with non-enum column' do
      it 'raises an ArgumentError' do
        expect { model.plugin :enum, :str_col }.to raise_error(ArgumentError)
      end
    end
  end

  describe '.enums' do
    before do
      model.plugin :enum, :enum_col, :enum_col2
    end
    it 'contains allowed values for enum' do
      expected = {
        enum_col: Set.new(%w'a b c'),
        enum_col2: Set.new(%w'd e f'),
      }
      expect(model.enums).to eq(expected)
    end
  end

  describe 'instance methods' do
    subject(:instance) do
      model.plugin :enum, :enum_col, :enum_col2
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
