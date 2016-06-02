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
    @sync = sync || Sync[Event, matching_attributes: [:faculty, :absolute_sequence_number, source: :teacher_timetable_slot_id]].new
  end

  # @param events [Array<Event>] events that should be synced to the database
  # @return [Array<Event>] events synced to the database
  def process_row(events)
    @sync.perform(events: events)
    @sync.results[:events]
  end

  # @return [Array<Event>] events synced to the database
  def generate_row
    if processed_row
      pop_processed_row
    else
      raise EndOfData
    end
  end

end
