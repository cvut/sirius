require 'celluloid'
require 'actors/etl_actor'
require 'event'
require 'interactors/sync'

class EventDestination
  include Celluloid
  include ETLActor

  def initialize(output)
    set_output(output)
    @sync = Sync[Event, matching_attributes: [:absolute_sequence_number, source: :teacher_timetable_slot_id]].new
  end

  def process_row(events)
    @sync.perform(events: events)
  end

end
