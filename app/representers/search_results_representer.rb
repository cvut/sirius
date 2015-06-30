require 'roar/decorator'
require 'roar/json/json_api'

class SearchResultsRepresenter < Roar::Decorator
  include Roar::JSON::JSONAPI

  type :results

  property :id
  property :type, getter: ->(*) { _data['_type'] }
  property :title

end
