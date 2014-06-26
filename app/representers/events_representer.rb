require 'collection_representer'
require 'event_representer'
require 'events_ical_formatting'

class EventsRepresenter < CollectionRepresenter
  self.representation_wrap = :events
  # TODO: See if EventRepresenter can be defined inline
  collection :events, decorator: EventRepresenter

  # FIXME: this should be handled on Grape's level
  def to_ical
    EventsIcalFormatting.new.call(events)
  end
end
