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
  nested :original_data do
    property :original_starts_at, as: :starts_at
    property :original_ends_at, as: :ends_at
    property :original_room_id, as: :room_id
  end

  links do
    property :course_id, as: :course
    property :room_id, as: :room
    collection :teacher_ids, as: :teachers
    collection :student_ids, as: :students
    property :applied_schedule_exception_ids, as: :applied_exceptions
  end

  # Compound requests are injected separately from to_hash
  compound do

    collection :courses, render_empty: false, getter: -> (args) { args[:courses] } do
      property :id
      property :name
    end

    collection :teachers, render_empty: false, getter: -> (args) { args[:teachers] } do
      property :id
      property :full_name
    end
  end

  def parallel
    represented.parallel.to_s
  end
end
