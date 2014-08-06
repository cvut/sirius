require 'collection_representer'
require 'event_representer'
require 'format_events_ical'

class EventsRepresenter < CollectionRepresenter
  self.representation_wrap = :events
  # TODO: See if EventRepresenter can be defined inline
  collection :events, decorator: EventRepresenter

  # FIXME: this should be handled on Grape's level
  def to_ical
    FormatEventsIcal.perform(events: represented).ical
  end
end
