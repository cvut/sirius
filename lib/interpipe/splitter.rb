require 'interpipe/organizer'
require 'interpipe/aliases'

module Interpipe
  class Splitter < Organizer
    extend Aliases

    def perform(**options)
      @results = interactors.map do |interactor|
        interactor.perform(options).results
      end
    end
  end
end
