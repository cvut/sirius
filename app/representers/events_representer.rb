require 'collection_representer'
class EventsRepresenter < CollectionRepresenter
  # TODO: See if EventRepresenter can be defined inline
  collection :events, decorator: EventRepresenter
end
