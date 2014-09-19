require 'interpipe/interactor'
require 'pp'

class DebugPipeline
  include Interpipe::Interactor

  def perform(**options)
    pp options
    @results = options
  end

end
