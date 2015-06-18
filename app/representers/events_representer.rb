require 'roar/json/json_api'

class EventsRepresenter < Roar::Decorator
  include Roar::JSON::JSONAPI
  type :events

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

  links do
    property :course_id, as: :course
    property :room, getter: -> (args) { room.to_s }
    collection :teacher_ids, as: :teachers
    collection :student_ids, as: :students
    property :applied_schedule_exception_ids, as: :applied_exceptions
  end

  def parallel
    represented.parallel.to_s
  end
end
