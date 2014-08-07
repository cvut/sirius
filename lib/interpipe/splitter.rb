require 'interpipe/organizer'
require 'interpipe/aliases'

module Interpipe
  class Splitter < Organizer
    extend Aliases

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
