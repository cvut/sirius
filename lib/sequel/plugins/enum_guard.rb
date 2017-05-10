# frozen_string_literal: true
require 'set'

module Sequel
  module Plugins
    # EnumGuard adds runtime checking for Sequel's [pg_enum][pg_enum] types.
    #
    # When enabled, the plugin automatically searches model's schema for enum fields
    # and adds custom setter to prevent invalid value to be set on enum field.
    # The plugin also adds `enums` class method to the model exposing Hash of known enum fields with
    # their value.
    #
    # The plugin was loosely inspired by [sequel_enum][sequel_enum] plugin.
    #
    # ### Example:
    #
    #     Sequel::Model.plugin :enum_guard # The plugin is intended to be enabled globally
    #
    #     class MyModel < Sequel::Model
    #     end
    #
    #     MyModel.enum_fields
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
    module EnumGuard
      # @return [void]
      def self.configure(model)
        model.instance_eval do
          send(:create_enum_setters) if @dataset
        end
      end

      module ClassMethods
        Plugins.after_set_dataset(self, :create_enum_setters)

        private
        def create_enum_setters
          columns = check_non_connection_error do
            db_schema.select {|_, val| val[:type] == :enum}
          end
          return if columns.empty?

          @enum_fields = columns.map{ |k, v| create_enum_setter(k, v) }.to_h
          @enum_fields.freeze
          class << self
            attr_reader :enum_fields
          end
        end

        def create_enum_setter(column, column_schema)
          enum_values = column_schema[:enum_values].to_set.freeze

          define_method "#{column}=" do |value|
            val_str = value.to_s
            unless enum_values.include? val_str
              raise ArgumentError, "Invalid enum value for #{column}: '#{val_str}'"
            end
            super(val_str)
          end

          [column, enum_values]
        end

      end
    end
  end
end
