require 'actors/etl_base'

# Consumer module for implementing ETL consumer - producer Actor protocol.
#
# For details about the protocol see comments on {ETLProducer}.
module ETLConsumer
  include ETLBase

  # Sets actor input for sending hungry notifications.
  #
  # @param input [Symbol] actor name in Celluloid actor registry
  def input=(input)
    @_input = input
  end

  # Receive a single row from actor's source(s).
  #
  # Actor specific #process_row implementation is called with received row
  # and the return value is stored in processed_row.
  def consume_row(row)
    raise "#{self.class.name}: Received row when not empty!" unless empty?
    self.processed_row = process_row(row)
    produce_row() if respond_to?(:produce_row)
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

  def processed_row=(row)
    @_processed_row = row
  end

  def pop_processed_row
    row = @_processed_row
    @_processed_row = nil
    row
  end

  def processed_row
    @_processed_row
  end
end
