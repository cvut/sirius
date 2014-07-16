require 'icalendar'
require 'role_playing'

##
# Converts {Event}'s collection to an ICalendar.
#
class EventsIcalFormatting
  include RolePlaying::Context

  # @param [Event, Array<Event>]
  def initialize(events)
    @events = Array(events) # Always work with collection
    @calendar = Icalendar::Calendar.new
  end

  ##
  # Adds events to an ICalendar and convert it to a text representation.
  # @return [String] ICalendar as a string.
  def call
    @events.each do |e|
      @calendar.add_event IcalEvent(e).to_ical
    end
    @calendar.to_ical
  end


  # Event to Icalendar::Event mapping.
  role :IcalEvent do

    # Maps {Event} attributes to {Icalendar::Event} object.
    # @return [Icalendar::Event]
    def to_ical
      ical_event = Icalendar::Event.new.tap do |e|
        e.summary = name
        e.description = note
        e.dtstart = starts_at.strftime("%Y%m%dT%H%M%S")
        e.dtend = ends_at.strftime("%Y%m%dT%H%M%S")
        e.location = '' # FIXME!
        e.ip_class = 'PUBLIC'
        e.created = self.created_at
        e.last_modified = self.updated_at
        #e.uid = e.url = "/events/#{self.id}" # FIXME!
        #e.add_comment()
      end
    end
  end

end
