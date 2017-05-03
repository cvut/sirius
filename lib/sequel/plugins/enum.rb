# frozen_string_literal: true
require 'set'

module Sequel
  module Plugins
    module Enum
      def self.apply(model, opts = OPTS)
        model.instance_eval do
          @enums = {}
        end
      end

      module ClassMethods
        attr_reader :enums

        def enum(*columns)
          columns.each do |column|
            enable_enum(column)
          end
        end

        private
        def enable_enum(column)
          column = column.to_sym
          enum_schema = db_schema[column]
          if enum_schema[:type] != :enum
            raise ArgumentError, "Enum column '#{column}' should be of type enum, got #{enum_schema[:type]}"
          end

          enum_values = enum_schema[:enum_values].to_set.freeze
          self.enums[column] = enum_values

          define_method "#{column}" do
            super().to_sym
          end

          define_method "#{column}=" do |value|
            val_str = value.to_s
            unless enum_values.include? val_str
              raise ArgumentError, "Invalid enum value for #{column}: '#{val_str}'"
            end
            super(val_str)
          end
        end

      end
    end
  end
end
