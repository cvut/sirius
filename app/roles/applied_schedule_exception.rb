require 'role_playing'

class AppliedScheduleException < RolePlaying::Role

  def affects?(event)
    period.include?(event.period)
  end

  def apply(event)
    case exception_type
      when ExceptionType::CANCEL then event.deleted = true
      else
        raise "Don't know how to apply #{exception_type}."
    end
  end


end
