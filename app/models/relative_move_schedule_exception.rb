class RelativeMoveScheduleException < ScheduleException

  def apply(event)
    super
    event.move(options[:offset])
  end
end
