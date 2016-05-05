require 'actors/etl_base'

# Consumer module for implementing ETL consumer - producer Actor protocol.
#
# For details about the protocol see comments on ETLProducer.
module ETLConsumer
  include ETLBase

  def input=(input)
    @_input = input
  end

  # Receive a single row from actor's source(s).
  def consume_row(row)
    raise "#{self.class.name}: Received row when not empty!" unless empty?
    process_row(row)
  end

  # Send asynchronous "hungry" notification to it's input (if it has one).
  #
  # Hungry notification means that more work should be sent to this actor.
  def notify_hungry
    if @_input
      logger.debug "Sending hungry notification to #{@_input}."
      Celluloid::Actor[@_input].async.receive_hungry
    else
      logger.debug "Nowhere to send hungry notification. No input specified."
    end
  end

  def start!
    mark_empty!
    notify_hungry
  end
end
