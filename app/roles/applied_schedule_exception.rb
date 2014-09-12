require 'role_playing'
require 'sirius/enums/schedule_exception_type'

class AppliedScheduleException < RolePlaying::Role

  def affects?(event)
    time_range_check = period.intersect?(event.period)
    faculty_check = true
    semester_check = true
    timetable_slot_check = true
    time_range_check && faculty_check && semester_check && timetable_slot_check
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
