require 'interpipe/organizer'
require 'interpipe/aliases'

module Interpipe
  class Pipe < Organizer
    extend Aliases

    def self.pipe(*interactors)
      @interactors = interactors.flatten
    end

    def perform(**options)
      @results = interactors.inject(options) do |result, interactor|
        interactor.perform(result).results
      end
    end
  end
end
