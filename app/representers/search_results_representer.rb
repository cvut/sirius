require 'roar/decorator'
require 'roar/json/json_api'

class SearchResultsRepresenter < Roar::Decorator
  include Roar::JSON::JSONAPI

  type :results

  property :id
  property :type
  property :title, render_nil: true

end
