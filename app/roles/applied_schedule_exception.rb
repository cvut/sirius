require 'role_playing'
require 'sirius/enums/schedule_exception_type'

class AppliedScheduleException < RolePlaying::Role

  def affects?(event)
    faculty_check = true
    semester_check = true
    time_range_check(event) && faculty_check && semester_check && timetable_slot_check(event)
  end

  def apply(event)
    case exception_type
    when Sirius::ScheduleExceptionType::CANCEL then event.deleted = true
    when Sirius::ScheduleExceptionType::RELATIVE_MOVE then event.move(options[:offset])
    else
      raise "Don't know how to apply #{exception_type}."
    end
  end

  private
  def time_range_check(event)
    period.intersect?(event.period)
  end

  def timetable_slot_check(event)
    return true if timetable_slot_ids.nil? || timetable_slot_ids.empty?
    timetable_slot_ids.include?(event.timetable_slot_id)
  end


end
