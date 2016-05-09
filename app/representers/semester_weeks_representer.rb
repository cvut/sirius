require 'roar/decorator'
require 'roar/json/json_api'

class SemesterWeeksRepresenter < Roar::Decorator
  include Roar::JSON::JSONAPI

  type :semester_weeks

  property :start_date, as: :starts_at
  property :end_date, as: :ends_at
  property :cweek
  property :period_types
  property :teaching_week, render_nil: true
  property :week_parity, render_nil: true

  links do
    property :semester, getter: ->(*) { "#{semester.faculty}-#{semester.code}" }
    collection :periods, getter: ->(*) { periods.map(&:id) }
  end
end
