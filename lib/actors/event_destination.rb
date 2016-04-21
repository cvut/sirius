require 'celluloid'
require 'actors/etl_consumer'
require 'event'
require 'interactors/sync'

class EventDestination
  include Celluloid
  include ETLConsumer

  def initialize(input, parent_actor)
    set_input(input)
    @parent_actor = parent_actor
    #set_output(output)
    @sync = Sync[Event, matching_attributes: [:absolute_sequence_number, source: :teacher_timetable_slot_id]].new
  end

  def process_row(events)
    @sync.perform(events: events)
    become_hungry
  end

  def receive_eof
    Celluloid::Actor[@parent_actor].async.receive_eof
  end

end
