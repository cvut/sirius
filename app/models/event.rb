require 'period'
require 'parallel'
require 'sequel/extensions/core_refinements'

class Event < Sequel::Model
  using Sequel::CoreRefinements

  many_to_one :room
  many_to_one :course
  many_to_one :parallel
  many_to_one :timetable_slot

  alias :sequence_number :relative_sequence_number

  def self.with_person(username)
    filter(:teacher_ids.pg_array.contains([username]))
      .or(:student_ids.pg_array.contains([username]))
  end

  def self.with_teacher(username)
    filter(:teacher_ids.pg_array.contains([username]))
  end

  def self.batch_delete(ids)
    where(id: ids, deleted: false).update(deleted: true, applied_schedule_exception_ids: nil)
  end

  def period
    Period.new(starts_at, ends_at)
  end

  def period=(new_period)
    self.starts_at = new_period.starts_at
    self.ends_at = new_period.ends_at
  end

  def move(offset)
    offset_int = offset.to_i
    self.original_starts_at ||= self.starts_at
    self.original_ends_at ||= self.ends_at
    self.starts_at += offset_int.minutes
    self.ends_at += offset_int.minutes
  end

end
