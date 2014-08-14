require 'interpipe/organizer'

module Interpipe
  class Pipe < Organizer
    def perform(**options)
      @results = interactors.inject(options) do |result, interactor|
        interactor.perform(result).results
      end
    end
  end
end
