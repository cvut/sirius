require 'role_playing'
require 'sirius/enums/schedule_exception_type'

class AppliedScheduleException < RolePlaying::Role

  def affects?(event)
    period.intersect?(event.period)
  end

  def apply(event)
    case exception_type
    when Sirius::ScheduleExceptionType::CANCEL then event.deleted = true
    when Sirius::ScheduleExceptionType::RELATIVE_MOVE then event.move(options[:offset])
    else
      raise "Don't know how to apply #{exception_type}."
    end
  end


end
