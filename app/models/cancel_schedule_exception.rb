class CancelScheduleException < ScheduleException

  def apply(event)
    super
    event.deleted = true
  end
end
