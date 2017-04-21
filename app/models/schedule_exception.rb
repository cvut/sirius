require 'period'
require 'sirius/enums/schedule_exception_type'

class ScheduleException < Sequel::Model
  plugin :single_table_inheritance, :exception_type, model_map: {
    0 => :CancelScheduleException,
    1 => :RelativeMoveScheduleException,
    2 => :RoomChangeScheduleException,
    3 => :TeacherChangeScheduleException
  }

  def period
    Period.new(starts_at, ends_at)
  end

  def period=(new_period)
    self.starts_at = new_period.starts_at
    self.ends_at = new_period.ends_at
  end

  def exception_type
    Sirius::ScheduleExceptionType.from_numeric(super)
  end

  def exception_type=(new_type)
    super Sirius::ScheduleExceptionType.to_numeric(new_type)
  end

  # Checks whether this exception affects an event during
  # event planning phase.
  def affects?(event)
    !event.deleted &&
    time_matches?(event) &&
    faculty_matches?(event) &&
    semester_matches?(event) &&
    course_matches?(event) &&
    timetable_slot_matches?(event)
  end

  # This method is called by inherited #apply implementations before their own code.
  def apply(event)
    event.applied_schedule_exception_ids ||= []
    event.applied_schedule_exception_ids << id
  end

  # Called when an exception is applied during assign people phase.
  # Should be overridden by subclass if needed.
  def apply_people_assign(event)
  end

  private
  def time_matches?(event)
    period.intersect?(event.period)
  end

  def timetable_slot_matches?(event)
    return true if timetable_slot_ids.nil? || timetable_slot_ids.empty?
    event.source_type == 'timetable_slot' && timetable_slot_ids.include?(event.source_id.to_i)
  end

  def course_matches?(event)
    return true if course_ids.nil? || course_ids.empty?
    course_ids.include?(event.course_id)
  end

  def faculty_matches?(event)
    return true if faculty.nil?
    faculty == event.faculty
  end

  def semester_matches?(event)
    return true if semester.nil?
    semester == event.semester
  end
end

# Load all inherited exception classes in app/models
Dir[File.dirname(__FILE__) + '/*_schedule_exception.rb'].each { |f| require f }
