require 'roar/decorator'
require 'roar/json/json_api'

class SemestersRepresenter < Roar::Decorator
  include Roar::JSON::JSONAPI

  type :semesters

  property :id, getter: ->(*) { "#{faculty}-#{code}" }
  property :code, as: :semester
  property :faculty
  property :starts_at
  property :ends_at
  property :exams_start_at
  property :exams_end_at
  property :teaching_ends_at
  property :first_week_parity
  property :hour_duration
  property :hour_starts, getter: ->(*) do
    hour_starts.map { |v| v.strftime('%H:%M') }
  end

  collection :semester_periods, as: :periods do
    property :type
    property :starts_at
    property :ends_at
    property :first_week_parity
  end

end
