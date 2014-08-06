require 'interpipe/interactor'

module Interpipe
  module Pipe
    def self.included(base)
      base.class_eval do
        include Interactor

        extend ClassMethods
        include InstanceMethods
      end
    end

    module ClassMethods
      def interactors
        @interactors ||= []
      end

      def pipe(*interactors)
        @interactors = interactors.flatten
      end
    end

    module InstanceMethods
      def interactors
        self.class.interactors
      end

      def perform(**options)
        @results = interactors.inject(options) do |result, interactor|
          interactor.perform(result).results
        end
      end
    end
  end
end
