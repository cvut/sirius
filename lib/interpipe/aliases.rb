module Interpipe
  module Aliases

    def pipe
      require 'interpipe/pipe'
      Interpipe::Pipe
    end

    def split
      require 'interpipe/splitter'
      Interpipe::Splitter
    end

  end
end

