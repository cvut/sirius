require 'celluloid'
require 'actors/etl_consumer'
require 'actors/etl_producer'
require 'event'
require 'interactors/sync'

class EventDestination
  include Celluloid
  include ETLConsumer
  include ETLProducer

  def initialize(input, output)
    self.input = input
    self.output = output
    @sync = Sync[Event, matching_attributes: [:absolute_sequence_number, source: :teacher_timetable_slot_id]].new
  end

  def process_row(events)
    @sync.perform(events: events)
    @saved_events = @sync.results[:events]
    unset_empty
    produce_row if buffer_empty?
  end

  def produce_row
    if @saved_events
      output_row(@saved_events)
      @saved_events = nil
    else
      notify_hungry
      emit_eof if eof_received?
    end
  end

end
