require 'roar/decorator'
require 'roar/json/json_api'

class SemesterDaysRepresenter < Roar::Decorator
  include Roar::JSON::JSONAPI

  type :semester_days

  property :date
  property :cwday
  property :period_type, getter: ->(*) { period.type }
  property :irregular
  property :teaching_week, render_nil: true
  property :week_parity, render_nil: true

  links do
    property :semester, getter: ->(*) { "#{semester.faculty}-#{semester.code}" }
    property :period, getter: ->(*) { period.id }
  end
end
