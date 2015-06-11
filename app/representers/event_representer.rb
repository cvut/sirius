# require 'roar/decorator'
require 'roar/json/json_api'

class EventRepresenter < Roar::Decorator
  # include Roar::JSON::JsonApi
  # name :events

  include Roar::JSON

  property :id, render_nil: true
  property :name, render_nil: true
  property :note
  property :relative_sequence_number, as: :sequence_number
  property :starts_at, render_nil: true
  property :ends_at, render_nil: true
  property :deleted
  property :capacity
  property :event_type
  property :parallel, exec_context: :decorator, render_nil: true
  property :links, exec_context: :decorator

  def parallel
    represented.parallel.to_s
  end


  def links
    # property :course_id, as: :course
    # property :room, getter: -> (args) { room.to_s }
    # collection :teacher_ids, as: :teachers
    # collection :student_ids, as: :students
    {
      course: represented.course_id,
      room: represented.room.try(:to_s),
      teachers: represented.teacher_ids,
      students: represented.student_ids,
      applied_exceptions: represented.applied_schedule_exception_ids
    }
  end
  # has_one :course
  # has_one :room
end
