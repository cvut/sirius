require 'interpipe/interactor'

module Interpipe
  ##
  # Abstract class for nesting interactors.
  # For solid implementations, see {Pipe} and {Splitter}
  class Organizer
    include Interactor

    def self.interactors
      @interactors ||= []
    end

    def self.interactors= (*interactors)
      @interactors = interactors.flatten
    end

    def interactors
      self.class.interactors
    end

    def perform(**options)
      raise NotImplementedError.new('Method #perform must be implemented')
    end
  end
end
