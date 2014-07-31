module Interpipe
  module Interactor
    def self.included(base)
      base.class_eval do
        extend ClassMethods

        attr_reader :context
      end
    end

    module ClassMethods
      def perform(options = {})
        new.perform(options)
      end
    end

    def perform(**options)
    end

  end
end
