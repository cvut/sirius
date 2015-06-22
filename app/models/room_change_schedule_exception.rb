class RoomChangeScheduleException < ScheduleException

  def apply(event)
    super
    event.original_room_id ||= event.room_id
    event.room_id = options[:room_id]
  end
end
