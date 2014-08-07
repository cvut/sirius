require 'interpipe/organizer'

module Interpipe
  class Pipe < Organizer

    def self.[](*interactors)
      anon_pipe = Class.new(self)
      anon_pipe.interactors = interactors
      anon_pipe
    end

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
