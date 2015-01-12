require 'interpipe/pipe'
require 'interpipe/aliases'
require 'interactors/sync'
require 'interactors/fetch_exam_students'
require 'models/person'
require 'models/course'
require 'models/parallel'

class ImportExamStudents < Interpipe::Pipe
  include Interpipe::Aliases

  @interactors = [
    FetchExamStudents,
    split[
      Sync[Person],
      Sync[Event]
    ]
  ]

end
