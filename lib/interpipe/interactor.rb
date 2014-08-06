module Interpipe
  module Interactor
    def self.included(base)
      base.class_eval do
        extend ClassMethods

        attr_reader :results
      end
    end

    module ClassMethods
      def perform(options = {})
        new.tap do |instance|
          instance.perform(options)
        end
      end
    end

    def initialize
      @results = {}
      setup
    end

    def setup
    end

    def perform(**options)
    end
  end
end
