require 'interpipe/pipe'
require 'interpipe/aliases'
require 'interactors/sync'
require 'interactors/fetch_students'
require 'models/person'
require 'models/course'
require 'models/parallel'

class ImportCourseEventStudents < Interpipe::Pipe
  include Interpipe::Aliases

  @interactors = [
    FetchStudents[:course_events, source_key: :course_event_id, event_types: ['course_event']],
    split[
      Sync[Person],
      Sync[Event]
    ]
  ]

end
