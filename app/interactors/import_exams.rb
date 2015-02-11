require 'interpipe/pipe'
require 'interpipe/aliases'
require 'interactors/sync'
require 'interactors/fetch_resource'
require 'interactors/convert_exams'
require 'interactors/extract_rooms'
require 'event'

class ImportExams < Interpipe::Pipe
  include Interpipe::Aliases

  @interactors = [
    FetchResource[:exams],
    ExtractRooms[collection: :exams],
    ConvertRooms,
    Sync[Room],
    ConvertExams,
    split[
      Sync[Person],
      Sync[Course],
      Sync[Event, matching_attributes: [source: :exam_id]]
    ]
  ]

end
