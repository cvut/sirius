require 'interpipe/pipe'
require 'interpipe/aliases'
require 'interactors/sync'
require 'interactors/fetch_students'
require 'models/person'
require 'models/course'
require 'models/parallel'

class ImportExamStudents < Interpipe::Pipe
  include Interpipe::Aliases

  @interactors = [
    FetchStudents[:exams, source_key: :exam_id, event_types: ['exam', 'assessment']],
    split[
      Sync[Person],
      Sync[Event]
    ]
  ]

end
