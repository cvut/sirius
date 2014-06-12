require 'base_representer'
require 'representable/json/collection'
class CollectionRepresenter < BaseRepresenter
  include Representable::JSON::Collection
end
