class EventRepresenter < BaseRepresenter
  include Roar::Representer::JSON

  property :id
  property :name
end
