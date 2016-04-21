require 'actors/etl_base'

module ETLConsumer
  include ETLBase

  def set_input(input)
    @_input = input
  end

  # Receive a single row from actor's source(s).
  def consume_row(row)
    raise "#{self.class.name}: Received row when not empty!" unless is_empty?
    process_row(row)
  end

  def become_hungry
    set_empty
    logger.debug "#{self.class.name} feels hungry."
    Celluloid::Actor[@_input].async.receive_hungry if @_input
  end

  def start!
    become_hungry
  end
end
