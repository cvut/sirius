require 'interpipe/interactor'

module Interpipe
  class Organizer
    include Interactor

    def self.interactors
      @interactors ||= []
    end

    def self.interactors=(interactors)
      @interactors = interactors
    end

    def interactors
      self.class.interactors
    end
  end
end
