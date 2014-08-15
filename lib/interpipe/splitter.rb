require 'interpipe/organizer'

module Interpipe
  class Splitter < Organizer

    def perform(**options)
      @results = interactors.map do |interactor|
        interactor.perform(options).results
      end
    end
  end
end
