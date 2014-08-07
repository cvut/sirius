module Interpipe
  module Aliases

    def pipe(*interactors)
      require 'interpipe/pipe'
      Pipe[*interactors]
    end

    def split(*interactors)
      require 'interpipe/splitter'
      Splitter[*interactors]
    end

  end
end
