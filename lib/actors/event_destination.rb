require 'celluloid'
require 'actors/etl_consumer'
require 'actors/etl_producer'
require 'event'
require 'interactors/sync'

# A consumer that receives and saves arrays of Events and then sends them to the next actor.
class EventDestination
  include Celluloid
  include ETLConsumer
  include ETLProducer

  def initialize(input, output, sync = nil)
    self.input = input
    self.output = output
    @sync = sync || Sync[Event, matching_attributes: [:absolute_sequence_number, source: :teacher_timetable_slot_id]].new
  end

  # @param events [Array<Event>] events that should be synced to the database
  def process_row(events)
    @sync.perform(events: events)
    @saved_events = @sync.results[:events]
  end

  # @return [Array<Event>] events synced to the database
  def generate_row
    if @saved_events
      row = @saved_events
      @saved_events = nil
      row
    else
      raise EndOfData
    end
  end

end
