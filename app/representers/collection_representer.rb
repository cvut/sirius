require 'base_representer'
require 'representable/json/collection'
class CollectionRepresenter < BaseRepresenter
  # FIXME: This will have to be changed from the lonely collection
  # to support `meta` properties
  include Representable::JSON::Collection
end
