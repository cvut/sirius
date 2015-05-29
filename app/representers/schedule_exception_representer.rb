# require 'roar/decorator'
require 'roar/json/json_api'

class ScheduleExceptionRepresenter < Roar::Decorator
  include Roar::JSON

  property :id, render_nil: true
  property :type, exec_context: :decorator
  property :name, render_nil: true
  property :note
  nested :scope do
    property :starts_at, render_nil: true
    property :ends_at, render_nil: true
    property :faculty, render_nil: true
    property :semester, render_nil: true
    property :course_ids, render_nil: true, as: :courses
    property :timetable_slot_ids, render_nil: true, as: :timetable_slots
  end
  hash :options

  def type
    represented.exception_type.upcase
  end
end
