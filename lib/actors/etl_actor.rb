module ETLActor

  def emit_row(row, *rest)
    Celluloid::Actor[@output].async.consume_row(row, rest)
  end

  def consume_row(row, rest)
    process_row(row, *rest)
    terminate_if_done!
  end

  def emit_eof
    Celluloid::Actor[@output].async.receive_eof if @output
  end

  def receive_eof
    puts "Receiving EOF to #{self.class.name} (#{Thread.current.object_id})."
    @eof_received = true
    terminate_if_done!
  end

  private

  def set_output(output)
    @output = output
  end

  def terminate_if_done!
    if tasks.count <= 1 && Celluloid.mailbox.size <= 0 && @eof_received
      puts "Terminating actor #{self.class.name} (#{Thread.current.object_id})."
      emit_eof
      terminate
    end
  end
end
