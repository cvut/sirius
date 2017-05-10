# frozen_string_literal: true
require 'set'

module Sequel
  module Plugins
    # Enum enhances Sequel's [pg_enum][pg_enum] types with extra runtime checking and symbol conversion.
    #
    # When enabled on model's field, the plugin:
    # - loads possible enum values from model's schema,
    # - prevents setting incorrect value on field,
    # - exposes known enum fields and values in `.enums` class method.
    #
    # The plugin is loosely inspired by [sequel_enum][sequel_enum] plugin.
    #
    # ### Example:
    #
    #     class MyModel < Sequel::Model
    #       plugin :enum, :column1, :column2  # Columns have to be enums, otherwise the initialization will fail
    #     end
    #
    #     MyModel.enums
    #     #=> {column1: ['a', 'b'], column2: ['c', 'd']}
    #
    #     instance = MyModel.new
    #     instance.column1 = 'a'  # Values can be set both as symbols or strings
    #     instance.column2 = :c
    #
    #     instance.column1        # Field's value is returned as string
    #     #=> 'a'
    #
    #     instance.column1 = 'invalid value'
    #     #=> ArgumentError
    #
    # [pg_enum]: http://sequel.jeremyevans.net/rdoc-plugins/files/lib/sequel/extensions/pg_enum_rb.html
    # [sequel_enum]: https://github.com/planas/sequel_enum
    module Enum
      # @private
      def self.apply(model)
        model.instance_eval do
          @enums = {}
        end
      end

      # Enables enum plugin for given columns.
      # @param [Array<Symbol>]
      # @raise [ArgumentError] if given column(s) do not exist or aren't enums
      # @return [void]
      def self.configure(model)
        model.instance_eval do
          send(:create_enum_accessors)
        end
      end

      module ClassMethods

        # @return [Hash{Symbol => Array<String>}] registered enum fields
        attr_reader :enums

        Plugins.inherited_instance_variables(self, :@enums=>:hash_dup)

        private
        def create_enum_accessors
          columns = db_schema.select {|_, val| val[:type] == :enum}
          columns.each do |col_name, col_schema|
            create_enum_accessor(col_name, col_schema)
          end
        end

        def create_enum_accessor(column, column_schema)
          if column_schema[:type] != :enum
            raise ArgumentError, "Enum column '#{column}' should be of type enum, got #{column_schema[:type]}"
          end

          enum_values = column_schema[:enum_values].to_set.freeze
          self.enums[column] = enum_values

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
