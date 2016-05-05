require 'actors/etl_base'
require 'end_of_data'

# Producer module for implementing ETL consumer - producer Actor protocol.
#
# ETL consumer - producer protocol with back-pressure is rather simple at it's core:
# There are two parties: producer and consumer that are both actor instances.
#
# - Producer produces (by loading, computing, generating, etc.) data (called rows)
# and sends them asynchronously to the consumer.
#
# - Consumer accepts rows from the producer and does something with them (saves them, sends
# them somewhere else, etc.).
#
# Because rows are exchanged asynchronously and consuming could be slower than producing,
# a way how to limit data flow between the actors is needed.
#
# This is solved by utilising back-pressure: Producer must only produce and send rows when consumer
# can accept them. The ability to receive rows is signalled by a message from the consumer to the producer.
# In response to that message a single row can be sent to the consumer. If the producer has no rows
# available for sending at the moment, it should internally store the state of it's consumer and send a row
# when it becomes available. After the consumer is finished with processing the received row, it requests
# another row from the producer and the cycle repeats.
#
module ETLProducer
  include ETLBase

  def output=(output)
    @_output = output
  end

  # Sends a single row to actor's output asynchronously.
  def emit_row(row)
    logger.debug "Emiting row: #{self.class.name} -> #{@_output}"
    Celluloid::Actor[@_output].async.consume_row(row)
  end

  # Sends EOF signal to actor's output (if it has one).
  def emit_eof
    logger.debug "Emiting EOF: #{self.class.name} -> #{@_output}"
    Celluloid::Actor[@_output].async.receive_eof if @_output
  end

  # Output a single row either to a local output buffer (in case output is stuffed)
  # or to the output directly.
  def output_row(row)
    if @_output_state == :hungry
      @_output_state = :stuffed
      emit_row(row)
      buffer_empty()
    else
      raise "Buffer not empty." unless @_buffer.nil?
      @_buffer = row
    end
  end

  def buffer_empty?
    @_buffer.nil?
  end

  # Receive work request from it's output.
  def receive_hungry
    return if output_hungry?
    if buffer_empty?
      @_output_state = :hungry
    else
      row = @_buffer
      @_buffer = nil
      emit_row(row)
      buffer_empty()
    end
  end

  def process_eof
    @_eof_received = true
    emit_eof if empty?
  end

  def output_hungry?
    @_output_state == :hungry
  end

  # Notification that output buffer was cleared and can receive more input.
  def buffer_empty
    produce_row() unless empty?
  end

  # Tries to generate a single row and then send it to the output or output buffer if the row was
  # successfully generated. If no row was generated, it sets empty flag and notifies its
  # input (if it has one).
  #
  # You should define #generate_row method on your producer actor, which returns either a single
  # row (pretty much anything) or throws EndOfData or StopIteration error in case there there
  # is no more rows to generate. (hint: Ruby's Enumerator#next behaves exactly like that)
  #
  def produce_row
    unmark_empty!
    begin
      output_row(generate_row())
      logger.debug "Generating a row."
    rescue StopIteration, EndOfData
      logger.debug "All pending rows processed."
      mark_empty!
      notify_hungry if respond_to? :notify_hungry
      emit_eof if eof_received?
    end
  end

end
