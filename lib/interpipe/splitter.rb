require 'interpipe/interactor'

module Interpipe
  module Splitter
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

      def split(*interactors)
        @interactors = interactors.flatten
      end
    end

    module InstanceMethods
      def interactors
        self.class.interactors
      end

      def perform(**options)
        @results = interactors.map do |interactor|
          interactor.perform(options).results
        end
      end
    end
  end
end
