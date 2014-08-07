require 'period'

class Event < Sequel::Model

  many_to_one :room
  many_to_one :course

  def self.for_person(username)
    teacher_op = Sequel.pg_array(:teacher_ids, :varchar)
    student_op = Sequel.pg_array(:student_ids, :varchar)
    filter(teacher_op.contains Sequel.pg_array([username]))#.or(student_op.contains [username])
  end

  def period
    Period.new(starts_at, ends_at)
  end

  def period=(new_period)
    self.starts_at = new_period.starts_at
    self.ends_at = new_period.ends_at
  end

end
