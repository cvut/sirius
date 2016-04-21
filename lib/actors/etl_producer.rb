require 'actors/etl_base'

module ETLProducer
  include ETLBase

  def set_output(output)
    @_output = output
  end

  # Sends a single row to actor's output asynchronously.
  def emit_row(row)
    logger.debug "Emiting row: #{self.class.name} -> #{@_output} (#{row.inspect})"
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
      logger.debug "#{@_output} is hungry, emitting."
      @_output_state = :stuffed
      emit_row(row)
      buffer_empty()
    else
      logger.debug "#{@_output} is stuffed, buffering."
      (@_buffer ||= []) << row
    end
  end

  def buffer_empty?
    (@_buffer ||= []).empty?
  end

  # Receive work request from it's output.
  def receive_hungry
    return if output_hungry?
    logger.debug "#{@_output} told me that he feels hungry."
    if buffer_empty?
      @_output_state = :hungry
    else
      emit_row(@_buffer.delete_at(0))
      buffer_empty()
    end
  end

  def process_eof
    @_eof_received = true
    emit_eof if is_empty?
  end

  def output_hungry?
    @_output_state == :hungry
  end

  # Notification that output buffer was cleared and can receive more input.
  def buffer_empty
    produce_row() unless is_empty?
  end

  # A default implementation of produce row.
  #
  # In case you require a custom producing logic, you can override this method in
  # your actor. In your implementation you must handle setting of empty/non_empty state, hungry notifications
  # and EOF emitting.
  #
  # If you are not overriding this, you should define #produce_row_iterable method on your
  # producer actor, which returns either a single row (pretty much anything) or throws StopIteration error
  # in case there there is no more output (hint: Ruby's Enumerator#next behaves exactly like that).
  #
  def produce_row
    unset_empty
    begin
      produce_row_iterable()
      logger.debug "Producing a row."
    rescue StopIteration
      logger.debug "All pending rows processed."
      set_empty
      become_hungry if respond_to? :become_hungry
      emit_eof if eof_received?
    end
  end

end
