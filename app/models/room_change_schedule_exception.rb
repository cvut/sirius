class RoomChangeScheduleException < ScheduleException

  def apply(event)
    super
    event.room_id = options[:room_id]
  end
end
