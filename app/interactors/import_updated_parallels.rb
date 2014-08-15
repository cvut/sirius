require 'interpipe/pipe'
require 'interpipe/aliases'
require 'interactors/fetch_updated_parallels'
require 'interactors/convert_parallels'
require 'interactors/sync'
require 'interactors/convert_tts'

class ImportUpdatedParallels < Interpipe::Pipe
  include Interpipe::Aliases

  interactors = [
      FetchUpdatedParallels,
      ConvertParallels,
      split[ Sync[Person], Sync[Course], Sync[Parallel],
        pipe[
            ConvertTTS,
            split[ Sync[Room, matching_attribute: :kos_code], Sync[TimetableSlot] ]
        ]
      ]
  ]

end
