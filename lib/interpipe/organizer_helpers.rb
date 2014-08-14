require 'interpipe/pipe'
require 'interpipe/splitter'
module Interpipe
  module OrganizerHelpers
    def Pipe(*interactors)
      Class.new(Pipe).tap do |pipe|
        pipe.interactors = interactors
      end
    end

    def Split(*interactors)
      Class.new(Splitter).tap do |splitter|
        splitter.interactors = interactors
      end
    end
  end
end
