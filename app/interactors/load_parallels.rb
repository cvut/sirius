require 'interpipe/interactor'
require 'parallel'

class LoadParallels
  include Interpipe::Interactor

  def perform(**options)
    @results = { parallels: Parallel.all }
  end

end
