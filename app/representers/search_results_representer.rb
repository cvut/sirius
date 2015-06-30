require 'roar/decorator'
require 'roar/json/json_api'

class SearchResultsRepresenter < Roar::Decorator
  include Roar::JSON::JSONAPI

  type :data

  # note: search result is just a Hash and Roar can't handle it by default
  property :id, getter: ->(*) { self[:id] }
  property :type, getter: ->(*) { self[:type] }
  property :title, getter: ->(*) { self[:title] }

end
