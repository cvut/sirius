require 'interpipe/pipe'
require 'interpipe/aliases'
require 'interactors/sync'
require 'interactors/fetch_resource'
require 'interactors/convert_exams'
require 'interactors/convert_rooms'
require 'interactors/convert_courses'
require 'interactors/convert_people'
require 'interactors/extract_items'
require 'event'

class ImportExams < Interpipe::Pipe
  include Interpipe::Aliases

  @interactors = [
    FetchResource[:exams],
    ConvertExams,
    split[
      pipe[ ExtractItems[:kosapi_people, from: :exams, attr: :examiner], ConvertPeople, Sync[Person] ],
      pipe[ ExtractItems[:kosapi_courses, from: :exams, attr: :course], ConvertCourses, Sync[Course] ],
      pipe[ ExtractItems[:kosapi_rooms, from: :exams, attr: :room], ConvertRooms, Sync[Room] ],
      Sync[Event, matching_attributes: [:faculty, :source_type, :source_id, :absolute_sequence_number]]
    ]
  ]

end
