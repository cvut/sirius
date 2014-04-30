require 'base_representer'
class EventRepresenter < BaseRepresenter
  include Roar::Representer::JSON

  property :id
  property :name
  property :starts_at
  property :ends_at
end
