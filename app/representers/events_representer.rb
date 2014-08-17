require 'roar/json/json_api'
require 'format_events_ical'

module EventsRepresenter
  include Roar::JSON::JsonApi
  name :events
  property :id
  property :name
  property :note
  property :absolute_sequence_number, as: :sequence_number
  property :starts_at
  property :ends_at


  links do
    property :course_id, as: :course
    property :room, getter: -> (args) { room.to_s }
    collection :teacher_ids, as: :teachers
    collection :student_ids, as: :students
  end
  # has_one :course
  # has_one :room

  # FIXME: this should be handled on Grape's level
  def to_ical
    FormatEventsIcal.perform(events: represented).ical
  end
end
