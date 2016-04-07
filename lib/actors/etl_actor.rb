# Module for handling ETL data flow between actors
# and their termination when the work is done.
#
# Include this module to your Celluloid actor to make it an ETL Actor.
# Basic ETLActor has no more than single output and can have any number of inputs.
# In your class you should implement #process_row method to handle
# the data transformation and processing.
#
# Passed data between ETL Actors is referenced as rows even if they
# do not correspond to any database row.
#
# All actor references are passed as symbols and are looked up in
# the Celluloid actor registry when used.
#
module ETLActor

  # Receive a single row from actor's source(s).
  def consume_row(row, rest = [])
    process_row(row, *rest)
    terminate_if_done!
  end

  # Receive EOF signal from actor's source(s).
  def receive_eof
    puts "Receiving EOF to #{self.class.name} (#{Thread.current.object_id})."
    @eof_received = true
    terminate_if_done!
  end

  private

  def set_output(output)
    @output = output
  end

  # Sends a single row to actor's output asynchronously.
  def emit_row(row, *rest)
    Celluloid::Actor[@output].async.consume_row(row, rest)
  end

  # Sends EOF signal to actor's output (if it has one).
  def emit_eof
    Celluloid::Actor[@output].async.receive_eof if @output
  end

  # Checks whether the actor is finished and should be terminated at the moment. Actor is
  # considered finished when it has received EOF and has empty mailbox.
  def terminate_if_done!
    if tasks.count <= 1 && Celluloid.mailbox.size <= 0 && @eof_received
      puts "Terminating actor #{self.class.name} (#{Thread.current.object_id})."
      emit_eof
      terminate
    end
  end
end
