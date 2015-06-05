require 'role_playing'
require 'sirius/enums/schedule_exception_type'

class AppliedScheduleException < RolePlaying::Role

  def affects?(event)
    time_range_check(event) && faculty_check(event) && semester_check(event) && course_check(event) && timetable_slot_check(event)
  end

  def apply(event)
    case exception_type
    when Sirius::ScheduleExceptionType::CANCEL then event.deleted = true
    when Sirius::ScheduleExceptionType::RELATIVE_MOVE then event.move(options[:offset])
    when Sirius::ScheduleExceptionType::ROOM_CHANGE then event.room_id = options[:room_id]
    else
      raise "Don't know how to apply #{exception_type}."
    end
    event.applied_schedule_exception_ids ||= []
    event.applied_schedule_exception_ids << id
  end

  private
  def time_range_check(event)
    period.intersect?(event.period)
  end

  def timetable_slot_check(event)
    return true if timetable_slot_ids.nil? || timetable_slot_ids.empty?
    timetable_slot_ids.include?(event.timetable_slot_id)
  end

  def course_check(event)
    return true if course_ids.nil? || course_ids.empty?
    course_ids.include?(event.course_id)
  end

  def faculty_check(event)
    return true if faculty.nil?
    faculty == event.faculty
  end

  def semester_check(event)
    return true if semester.nil?
    semester == event.semester
  end

end
