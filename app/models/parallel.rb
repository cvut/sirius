require 'models/person'
require 'models/course'
require 'models/timetable_slot'
require 'sirius/event_factory'
require 'sirius/teaching_time'

class Parallel < Sequel::Model

  many_to_one :course
  one_to_many :timetable_slots

  def self.for_teacher(teacher_id)
    array_op = Sequel.pg_array(:teacher_ids)
    filter(array_op.contains([teacher_id]))
    # alternative: filter(teacher_id => array_op.any)
  end

  def to_s
    code.to_s
  end

end
