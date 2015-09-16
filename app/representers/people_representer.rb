require 'roar/decorator'
require 'roar/json/json_api'

class PeopleRepresenter < Roar::Decorator
  include Roar::JSON::JSONAPI
  type :people

  property :id
  property :full_name, render_nil: true
  property :access_token, render_nil: true

end
