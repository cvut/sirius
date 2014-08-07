require 'interpipe/organizer'

module Interpipe
  class Splitter < Organizer

    def self.split(*interactors)
      @interactors = interactors.flatten
    end

    def perform(**options)
      @results = interactors.map do |interactor|
        interactor.perform(options).results
      end
    end
  end
end
