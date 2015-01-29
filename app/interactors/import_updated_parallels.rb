require 'interpipe/pipe'
require 'interpipe/aliases'
require 'interactors/fetch_updated_parallels'
require 'interactors/convert_parallels'
require 'interactors/sync'
require 'interactors/convert_rooms'
require 'interactors/convert_tts'
require 'models/person'
require 'models/course'
require 'models/parallel'

class ImportUpdatedParallels < Interpipe::Pipe
  include Interpipe::Aliases

  @interactors = [
      FetchUpdatedParallels,
      ConvertParallels,
      split[
        Sync[Person], Sync[Course], Sync[Parallel, skip_updating: [:student_ids]],
        pipe[
            ConvertRooms,
            Sync[Room],
            ConvertTTS,
            Sync[TimetableSlot]
        ]
      ]
  ]

end
