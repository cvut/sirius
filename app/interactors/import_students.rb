require 'interpipe/pipe'
require 'interpipe/aliases'
require 'interactors/sync'
require 'person'
require 'interactors/load_parallels'
require 'interactors/fetch_parallel_students'
require 'interactors/update_parallel_students'


class ImportStudents < Interpipe::Pipe
  include Interpipe::Aliases

  @interactors = [
      LoadParallels,
      FetchParallelStudents,
      UpdateParallelStudents,
      Sync[Person]
  ]

end
