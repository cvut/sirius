require 'models/person'
require 'models/course'
require 'models/timetable_slot'
require 'sirius/event_factory'
require 'sirius/teaching_time'
require 'sequel/extensions/core_refinements'

class Parallel < Sequel::Model
  using Sequel::CoreRefinements

  many_to_one :course
  one_to_many :timetable_slots

  def self.for_teacher(teacher_id)
    filter(:teacher_ids.pg_array.contains([teacher_id]))
    # alternative: filter(teacher_id => :teacher_ids.pg_array.any)
  end

  def to_s
    code.to_s
  end

end
