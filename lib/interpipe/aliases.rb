require 'interpipe/pipe'
require 'interpipe/splitter'
module Interpipe
  module Aliases


    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def pipe
        Interpipe::Pipe
      end
      def split
        Interpipe::Splitter
      end
    end
  end
end

