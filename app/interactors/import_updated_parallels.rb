require 'interactors/fetch_updated_parallels'
require 'interactors/convert_parallels'
require 'interactors/sync'
require 'interactors/convert_tts'
require 'interpipe/pipe'

class ImportUpdatedParallels < Interpipe::Pipe

  interactors = [
      FetchUpdatedParallels,
      ConvertParallels,
      split[ Sync[Person], Sync[Course], Sync[Parallel],
        pipe[
            ConvertTTS,
            split[ Sync[Room], Sync[TimetableSlot] ]
        ]
      ]
  ]

end
