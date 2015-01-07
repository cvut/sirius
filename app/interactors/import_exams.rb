require 'interpipe/pipe'
require 'interpipe/aliases'
require 'interactors/sync'
require 'interactors/fetch_exams'
require 'interactors/convert_exams'
require 'event'

class ImportExams < Interpipe::Pipe
  include Interpipe::Aliases

  @interactors = [
    FetchExams,
    ConvertExams,
    split[
      Sync[Person],
      Sync[Course],
      Sync[Event, matching_attributes: [source: :exam_id]]
    ]
  ]

end
