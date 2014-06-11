require 'representable/json/collection'
require 'base_representer'
class CollectionRepresenter < BaseRepresenter
  include Roar::Representer::JSON
end
