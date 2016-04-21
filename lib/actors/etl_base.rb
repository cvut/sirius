# Methods shared between ETLConsumer and ETLProducer modules.
module ETLBase

  def eof_received?
    @_eof_received || false
  end

  # Receive EOF signal from actor's source(s).
  def receive_eof
    logger.debug "Receiving EOF to #{self.class.name} (#{Thread.current.object_id})."
    process_eof if respond_to? :process_eof
  end

  def logger
    @_logger ||= Logging.logger[self]
  end

  # Sets the "empty" state for an actor. Actor should be empty
  # when it can't produce any more rows from the input it has already received.
  def set_empty
    @_empty = true
  end

  # Resets the "empty" state for an actor. Actor is not empty, when it can
  # produce more rows from the input it has already received.
  def unset_empty
    @_empty = false
  end

  # Checks whether an actor is currently "empty", meaning it can not produce any more output.
  def is_empty?
    @_empty
  end

end
